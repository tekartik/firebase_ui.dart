import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';

// ignore: unused_import, depend_on_referenced_packages

String? gDebugUsername;
String? gDebugPassword;

class AuthFlutterLoginScreen extends StatefulWidget {
  const AuthFlutterLoginScreen({super.key});

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
    return ValueStreamBuilder(
        stream: bloc.state,
        builder: (context, snapshot) {
          return SignInScreen(
              //providers: providers
              actions: [
                SignedOutAction((context) {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }),
              ]);
        });
  }
}

Widget authFlutterLoginScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
    blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
    child: const AuthFlutterLoginScreen());
