import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_flutter_widget/view/body_container.dart';
import 'package:tekartik_app_flutter_widget/view/body_h_padding.dart';
import 'package:tekartik_app_flutter_widget/view/busy_indicator.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth/auth.dart';

import 'auth_screen_bloc.dart';
// ignore: unused_import, depend_on_referenced_packages

class AuthProfileScreen extends StatefulWidget {
  const AuthProfileScreen({super.key});

  @override
  State<AuthProfileScreen> createState() => _AuthProfileScreenState();
}

class _AuthProfileScreenState extends State<AuthProfileScreen>
    with BusyScreenStateMixin<AuthProfileScreen> {
  @override
  void dispose() {
    busyDispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      if (mounted) {
        var bloc = BlocProvider.of<AuthScreenBloc>(context);
        await for (var authState in bloc.state) {
          if (!authState.signedIn) {
            if (mounted) {
              Navigator.of(context).pop(null);
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
          var title = 'Profile';
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
                    Center(
                      child: ListView(children: [
                        BodyContainer(
                          child: Column(
                            children: [
                              Text('Logged in as ${userState.user?.email}'),
                              const SizedBox(
                                height: 16,
                              ),
                              BodyHPadding(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _logout(bloc);
                                    /*
                                                            auth.signInWithEmailAndPassword(
                                                                usernameController.text
                                                                    .trim(),
                                                                passwordController.text
                                                                    .trim());*/
                                  },
                                  child: const Text('Logout'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ]),
                    ),
                    BusyIndicator(busy: busyStream),
                  ],
                );
              },
            ),
          );
        });
  }

  Future<void> _logout(AuthScreenBloc bloc) async {
    await busyAction(() async {
      try {
        await bloc.firebaseAuth.signOut();

        await Future<void>.delayed(const Duration(milliseconds: 300));
      } catch (e, st) {
        if (kDebugMode) {
          print('Error $e');
        }
        if (kDebugMode) {
          print(st);
        }
      }
    });
  }
}

/// Auth profile screen
Widget authProfileScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
    blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
    child: const AuthProfileScreen());
