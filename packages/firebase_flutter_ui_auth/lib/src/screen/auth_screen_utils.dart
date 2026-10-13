import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart'
    as fba
    show FirebaseAuthException;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';

/// Pops the screen of [state] with the user the first time the auth state
/// matches [when].
void authFlutterScreenPopWhen(
  State state, {
  required bool Function(AuthScreenBlocState authState) when,
}) {
  scheduleMicrotask(() async {
    if (!state.mounted) {
      return;
    }
    var bloc = BlocProvider.of<AuthScreenBloc>(state.context);
    await for (var authState in bloc.state) {
      if (when(authState)) {
        if (state.mounted) {
          Navigator.of(state.context).pop(authState.user);
        }
        return;
      }
    }
  });
}

/// The actions of the native sign in and register screens.
List<FirebaseUIAction> authFlutterAccountActions(AuthScreenBloc bloc) => [
  _anonymousUpgradedAction(bloc),
  _existingAccountAction(bloc),
];

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
