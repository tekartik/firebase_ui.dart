import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';

/// Auth register screen (native firebase_ui_auth [RegisterScreen]).
///
/// The native screen has no app bar and the sign-in switch is hidden, so an
/// [AppBar] (with its back button) is added on top of it to allow leaving
/// the screen.
class AuthFlutterRegisterScreen extends StatefulWidget {
  /// Auth register screen
  const AuthFlutterRegisterScreen({super.key});

  @override
  State<AuthFlutterRegisterScreen> createState() =>
      _AuthFlutterRegisterScreenState();
}

class _AuthFlutterRegisterScreenState extends State<AuthFlutterRegisterScreen> {
  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      if (mounted) {
        var bloc = BlocProvider.of<AuthScreenBloc>(context);
        await for (var authState in bloc.state) {
          if (authState.signedIn) {
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
    var intl = appIntl(context);
    return ValueStreamBuilder(
      stream: bloc.state,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: Text(intl.registerTitle)),
          body: RegisterScreen(
            auth: bloc.firebaseAuth.nativeInstance,
            showAuthActionSwitch: false,
          ),
        );
      },
    );
  }
}

/// Auth register screen
Widget authFlutterRegisterScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: const AuthFlutterRegisterScreen(),
);
