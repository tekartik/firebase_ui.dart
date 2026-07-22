import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';

/// Auth login screen
class AuthFlutterEmailVerificationScreen extends StatefulWidget {
  /// Auth login screen
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

    scheduleMicrotask(() async {
      if (mounted) {
        var bloc = BlocProvider.of<AuthScreenBloc>(context);
        await for (var authState in bloc.state) {
          if (!authState.signedIn) {
            if (mounted) {
              Navigator.of(context).pop();
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
        return EmailVerificationScreen(
          auth: bloc.firebaseAuth.nativeInstance,
          actions: [
            EmailVerifiedAction(() {
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
        );
      },
    );
  }
}

/// Auth login screen
Widget authFlutterLoginScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: const AuthFlutterEmailVerificationScreen(),
);
