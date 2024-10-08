import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_flutter_widget/view/body_container.dart';
import 'package:tekartik_app_flutter_widget/view/body_h_padding.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';

import 'auth_screen_bloc.dart';
// ignore: unused_import, depend_on_referenced_packages

/// debug username
String? gDebugUsername;

/// debug password
String? gDebugPassword;

/// Auth login screen
class AuthLoginScreen extends StatefulWidget {
  /// Auth login screen
  const AuthLoginScreen({super.key});

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends AutoDisposeBaseState<AuthLoginScreen>
    with AutoDisposedBusyScreenStateMixin<AuthLoginScreen> {
  late final usernameController =
      audiAddTextEditingController(TextEditingController(text: gDebugUsername));
  late final passwordController =
      audiAddTextEditingController(TextEditingController(text: gDebugPassword));
  late final _loginEnabled =
      audiAddBehaviorSubject(BehaviorSubject<bool>.seeded(false));

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
    var intl = appIntl(context);
    return ValueStreamBuilder(
        stream: bloc.state,
        builder: (context, snapshot) {
          var title = intl.loginTitle;
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
                                      decoration: InputDecoration(
                                        labelText: intl.loginUserLabel,
                                        border: const OutlineInputBorder(),
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
                                      decoration: InputDecoration(
                                        labelText: intl.loginPasswordLabel,
                                        border: const OutlineInputBorder(),
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
                                  ValueStreamBuilder(
                                      stream: _loginEnabled,
                                      builder: (context, snapshot) {
                                        var enabled = snapshot.data ?? false;
                                        return BodyHPadding(
                                          child: ElevatedButton(
                                            onPressed: enabled
                                                ? () async {
                                                    await _login(context, bloc);
                                                    /*
                                                          auth.signInWithEmailAndPassword(
                                                              usernameController.text
                                                                  .trim(),
                                                              passwordController.text
                                                                  .trim());*/
                                                  }
                                                : null,
                                            child: Text(intl.loginButtonLabel),
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

  Future<void> _login(BuildContext context, AuthScreenBloc bloc) async {
    if (_checkLoginEnabled()) {
      await busyAction(() async {
        try {
          var username = usernameController.text.trim();
          var password = passwordController.text.trim();

          await bloc.firebaseAuth
              .signInWithEmailAndPassword(email: username, password: password);

          await Future<void>.delayed(const Duration(milliseconds: 300));
        } catch (e, st) {
          if (kDebugMode) {
            print('Error $e');
          }
          if (kDebugMode) {
            print(st);
          }
          if (context.mounted) {
            unawaited(muiSnack(context, appIntl(context).loginGenericError));
          }
        } finally {
          _checkLoginEnabled();
        }
      });
    }
  }
}

/// Auth login screen
Widget authLoginScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
    blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
    child: const AuthLoginScreen());
