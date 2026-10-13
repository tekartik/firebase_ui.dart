import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';

import '../legacy_material.dart';
import 'auth_screen_utils.dart';

/// Auth email verification screen (native firebase_ui_auth screen)
class AuthFlutterEmailVerificationScreen extends StatefulWidget {
  /// Auth email verification screen
  const AuthFlutterEmailVerificationScreen({super.key});

  @override
  State<AuthFlutterEmailVerificationScreen> createState() =>
      _AuthFlutterEmailVerificationScreenState();
}

class _AuthFlutterEmailVerificationScreenState
    extends State<AuthFlutterEmailVerificationScreen> {
  @override
  void initState() {
    super.initState();

    authFlutterScreenPopWhen(this, when: (authState) => !authState.signedIn);
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    return ValueStreamBuilder(
      stream: bloc.state,
      builder: (context, snapshot) {
        return legacyMaterialScreen(
          EmailVerificationScreen(
            auth: bloc.firebaseAuth.nativeInstance,
            actions: [
              EmailVerifiedAction(() {
                // Upstream reloads the native user, which only fires
                // userChanges: reload through the bloc auth so the other
                // screens (the hub) see the verified email.
                unawaited(bloc.firebaseAuth.reloadCurrentUser());
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }),

              AuthCancelledAction((context) {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }),
            ],
          ),
        );
      },
    );
  }
}

/// Auth email verification screen
Widget authFlutterEmailVerificationScreen({FirebaseAuth? firebaseAuth}) =>
    BlocProvider(
      blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
      child: const AuthFlutterEmailVerificationScreen(),
    );
