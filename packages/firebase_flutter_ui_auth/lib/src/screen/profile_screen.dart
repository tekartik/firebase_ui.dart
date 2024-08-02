import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_flutter_widget/view/body_container.dart';
import 'package:tekartik_app_flutter_widget/view/busy_indicator.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

// ignore: unused_import, depend_on_referenced_packages

class AuthFlutterProfileScreen extends StatefulWidget {
  const AuthFlutterProfileScreen({super.key});

  @override
  State<AuthFlutterProfileScreen> createState() =>
      _AuthFlutterProfileScreenState();
}

class _AuthFlutterProfileScreenState extends State<AuthFlutterProfileScreen>
    with BusyScreenStateMixin<AuthFlutterProfileScreen> {
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
                              ProfileScreen(
                                  //providers: providers
                                  actions: [
                                    SignedOutAction((context) {
                                      Navigator.pop(context);
                                    }),
                                  ]),
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
}

/// Auth profile screen
Widget authFlutterProfileScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
    blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
    child: const AuthFlutterProfileScreen());
