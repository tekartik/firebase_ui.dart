import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_rx/helpers.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/src/view/body_container.dart';
import 'package:tekartik_firebase_ui_auth/src/view/body_h_padding.dart';
// ignore: unused_import, depend_on_referenced_packages

String? gDebugUsername;
String? gDebugPassword;

class LoginScreen extends StatefulWidget {
  final FirebaseAuth firebaseAuth;
  const LoginScreen({super.key, required this.firebaseAuth});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController(text: gDebugUsername);
  final passwordController = TextEditingController(text: gDebugPassword);
  final loginEnabled = ValueNotifier<bool>(false);
  final busy = ValueNotifier<bool>(false);

  late final _currentUserSubject =
      firebaseAuth.onCurrentUser.toBroadcastValueStream();
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    loginEnabled.dispose();
    _currentUserSubject.close();

    super.dispose();
  }

  FirebaseAuth get firebaseAuth => widget.firebaseAuth;
  @override
  void initState() {
    _checkLoginEnabled();
    super.initState();
    () async {
      await for (var user in _currentUserSubject) {
        if (mounted && user != null) {
          Navigator.of(context).pop(user);
        }
      }
    }();
  }

  void _checkLoginEnabled() {
    loginEnabled.value = usernameController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        !busy.value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueStreamBuilder(
        stream: _currentUserSubject,
        builder: (context, snapshot) {
          var title = 'Login';
          // var user = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),
            body: Builder(
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  children: [
                    ListView(children: [
                      BodyContainer(
                        child: Column(children: [
                          Form(
                            child: BodyContainer(
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  BodyHPadding(
                                    child: TextFormField(
                                      controller: usernameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Utilisateur',
                                        border: OutlineInputBorder(),
                                        //hintText: 'Email',
                                      ),
                                      onChanged: (value) {
                                        _checkLoginEnabled();
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  BodyHPadding(
                                    child: TextFormField(
                                      textInputAction: TextInputAction.done,
                                      obscureText: true,
                                      controller: passwordController,
                                      decoration: const InputDecoration(
                                        labelText: 'Mot de passe',
                                        border: OutlineInputBorder(),
                                        //hintText: 'Email',
                                      ),
                                      onChanged: (value) {
                                        _checkLoginEnabled();
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  ValueListenableBuilder<bool>(
                                      valueListenable: loginEnabled,
                                      builder: (context, enabled, _) {
                                        return BodyHPadding(
                                          child: ElevatedButton(
                                            onPressed: enabled
                                                ? () async {
                                                    await _login();
                                                    /*
                                                          auth.signInWithEmailAndPassword(
                                                              usernameController.text
                                                                  .trim(),
                                                              passwordController.text
                                                                  .trim());*/
                                                  }
                                                : null,
                                            child: const Text('Login'),
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ),
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

  Future<void> _login() async {
    busy.value = true;
    _checkLoginEnabled();

    try {
      var username = usernameController.text.trim();
      var password = passwordController.text.trim();

      await firebaseAuth.signInWithEmailAndPassword(
          email: username, password: password);

      await Future<void>.delayed(const Duration(milliseconds: 300));
    } catch (e, st) {
      if (kDebugMode) {
        print('Error $e');
      }
      if (kDebugMode) {
        print(st);
      }
    } finally {
      busy.value = false;
      _checkLoginEnabled();
    }
  }
}
