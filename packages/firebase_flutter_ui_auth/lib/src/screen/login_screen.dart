import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart'
    as fba
    show FirebaseAuthException;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';

import '../legacy_material.dart';

/// Debug username
String? gDebugUsername;

/// Debug password
String? gDebugPassword;

/// Auth login screen (native firebase_ui_auth [SignInScreen]).
class AuthFlutterLoginScreen extends StatefulWidget {
  /// Options (register switch).
  final FirebaseUiAuthOptions options;

  /// Auth login screen
  const AuthFlutterLoginScreen({
    super.key,
    this.options = firebaseUiAuthOptionsDefault,
  });

  @override
  State<AuthFlutterLoginScreen> createState() => _AuthFlutterLoginScreenState();
}

class _AuthFlutterLoginScreenState extends State<AuthFlutterLoginScreen> {
  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      if (mounted) {
        var bloc = BlocProvider.of<AuthScreenBloc>(context);
        await for (var authState in bloc.state) {
          // Not for an anonymous user: they came to get an account.
          if (authState.hasAccount) {
            if (mounted) {
              Navigator.of(context).pop(authState.user);
            }
            return;
          }
        }
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    return ValueStreamBuilder(
      stream: bloc.state,
      builder: (context, snapshot) {
        return legacyMaterialScreen(
          SignInScreen(
            auth: bloc.firebaseAuth.nativeInstance,
            showAuthActionSwitch: widget.options.registerEnabled,
            actions: [
              SignedOutAction((context) {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }),
              _anonymousUpgradedAction(bloc),
              _existingAccountAction(bloc),
            ],
          ),
        );
      },
    );
  }
}

/// An anonymous user signing up keeps its uid (the account is linked to
/// it): no auth state change, reload the user so the screens see the
/// account.
FirebaseUIAction _anonymousUpgradedAction(AuthScreenBloc bloc) =>
    AuthStateChangeAction<CredentialLinked>((context, state) {
      unawaited(bloc.firebaseAuth.reloadCurrentUser());
    });

/// An anonymous user signing in with a provider (Google) to an account that
/// exists already: flutterfire links the credential to the anonymous user,
/// which fails as it is in use; sign in to that account instead (the user
/// changes).
FirebaseUIAction _existingAccountAction(AuthScreenBloc bloc) =>
    AuthStateChangeAction<AuthFailed>((context, state) {
      var exception = state.exception;
      if (exception is! fba.FirebaseAuthException ||
          exception.code != 'credential-already-in-use') {
        return;
      }
      var credential = exception.credential;
      if (credential == null) {
        return;
      }
      unawaited(() async {
        try {
          await bloc.firebaseAuth.nativeInstance.signInWithCredential(
            credential,
          );
        } catch (e) {
          debugPrint('sign in to the existing account failed: $e');
        }
      }());
    });

/// Auth login screen
Widget authFlutterLoginScreen({
  FirebaseAuth? firebaseAuth,
  FirebaseUiAuthOptions options = firebaseUiAuthOptionsDefault,
}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: AuthFlutterLoginScreen(options: options),
);
