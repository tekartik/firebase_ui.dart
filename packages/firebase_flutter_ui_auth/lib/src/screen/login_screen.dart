import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_flutter_widget/view/body_container.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

// ignore: unused_import, depend_on_referenced_packages

String? gDebugUsername;
String? gDebugPassword;

class AuthFlutterLoginScreen extends StatefulWidget {
  const AuthFlutterLoginScreen({super.key});

  @override
  State<AuthFlutterLoginScreen> createState() => _AuthFlutterLoginScreenState();
}

class _AuthFlutterLoginScreenState extends State<AuthFlutterLoginScreen>
    with BusyScreenStateMixin<AuthFlutterLoginScreen> {
  final usernameController = TextEditingController(text: gDebugUsername);
  final passwordController = TextEditingController(text: gDebugPassword);
  final _loginEnabled = ValueNotifier<bool>(false);

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _loginEnabled.dispose();
    busyDispose();
    super.dispose();
  }

  @override
  void initState() {
    _checkLoginEnabled();
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

  bool _checkLoginEnabled() {
    var loginEnabled = usernameController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        !busy;
    _loginEnabled.value = loginEnabled;
    return loginEnabled;
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    return ValueStreamBuilder(
        stream: bloc.state,
        builder: (context, snapshot) {
          var title = 'Login';
          var userState = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: Builder(
              builder: (context) {
                if (userState == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  children: [
                    ListView(children: [
                      BodyContainer(
                        child: Column(children: [
                          ProfileScreen(
                              //providers: providers
                              actions: [
                                SignedOutAction((context) {
                                  Navigator.pop(context);
                                }),
                              ])
                        ]),
                      )
                    ]),
                    //BusyIndicator(busy: busy),
                  ],
                );
              },
            ),
          );
        });
  }
}

Widget authFlutterLoginScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
    blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
    child: const AuthFlutterLoginScreen());
