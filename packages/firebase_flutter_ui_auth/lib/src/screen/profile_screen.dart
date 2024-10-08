import 'dart:async';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

// ignore: unused_import, depend_on_referenced_packages

/// Auth profile screen
class AuthFlutterProfileScreen extends StatefulWidget {
  /// Auth profile screen
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
    var intl = appIntl(context);
    return ValueStreamBuilder(
        stream: bloc.state,
        builder: (context, snapshot) {
          var title = intl.profileTitle;
          return ProfileScreen(
              appBar: AppBar(
                title: Text(title),
              ),
              auth: bloc.firebaseAuth.nativeInstance,

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

/// Auth profile screen
Widget authFlutterProfileScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
    blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
    child: const AuthFlutterProfileScreen());
