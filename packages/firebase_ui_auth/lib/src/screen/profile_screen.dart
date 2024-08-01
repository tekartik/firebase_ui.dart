import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_rx/helpers.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/src/view/body_container.dart';
import 'package:tekartik_firebase_ui_auth/src/view/body_h_padding.dart';
// ignore: unused_import, depend_on_referenced_packages

class ProfileScreen extends StatefulWidget {
  final FirebaseAuth firebaseAuth;
  const ProfileScreen({super.key, required this.firebaseAuth});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final busy = ValueNotifier<bool>(false);

  late final _currentUserSubject =
      firebaseAuth.onCurrentUser.toBroadcastValueStream();
  @override
  void dispose() {
    _currentUserSubject.close();

    super.dispose();
  }

  FirebaseAuth get firebaseAuth => widget.firebaseAuth;
  @override
  void initState() {
    super.initState();
    () async {
      await for (var user in _currentUserSubject) {
        if (mounted && user == null) {
          Navigator.of(context).pop(user);
        }
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return ValueStreamBuilder(
        stream: _currentUserSubject,
        builder: (context, snapshot) {
          var title = 'Profile';
          var user = snapshot.data;

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
                    Center(
                      child: ListView(children: [
                        BodyContainer(
                          child: Column(
                            children: [
                              Text('Logged in as ${user?.email}'),
                              const SizedBox(
                                height: 16,
                              ),
                              BodyHPadding(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _logout();
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
                    )

                    //BusyIndicator(busy: busy),
                  ],
                );
              },
            ),
          );
        });
  }

  Future<void> _logout() async {
    busy.value = true;

    try {
      await firebaseAuth.signOut();

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
    }
  }
}
