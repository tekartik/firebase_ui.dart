import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/body_container.dart';
import 'package:tekartik_app_flutter_widget/view/body_h_padding.dart';
import 'package:tekartik_app_flutter_widget/view/busy_indicator.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';

import 'auth_screen_bloc.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

/// Auth screen
class AuthScreen extends StatefulWidget {
  /// Auth screen
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends AutoDisposeBaseState<AuthScreen>
    with AutoDisposedBusyScreenStateMixin<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    var intl = appIntl(context);
    return ValueStreamBuilder(
        stream: bloc.state,
        builder: (context, snapshot) {
          var state = snapshot.data;
          return Scaffold(
              appBar: AppBar(
                title: Text(intl.authTitle),
              ),
              body: Stack(
                children: [
                  Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        if (state == null)
                          const CircularProgressIndicator()
                        else
                          BodyContainer(
                            child: Column(
                              children: [
                                if (state.signedIn)
                                  BodyHPadding(
                                    child: Center(
                                      child: Text(
                                          intl.profileLoggedInAs(
                                              state.user!.email ??
                                                  state.user!.displayName ??
                                                  'user'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ),
                                  ),
                                BodyHPadding(
                                  child: IntrinsicWidth(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(
                                        width: 160,
                                      ),
                                      if (!state.signedIn)
                                        ElevatedButton(
                                            onPressed: () {
                                              _goToLoginScreen(context,
                                                  firebaseAuth:
                                                      bloc.firebaseAuth);
                                            },
                                            child: Text(intl.loginButtonLabel)),
                                      const SizedBox(height: 16),
                                      if (state.signedIn) ...[
                                        ElevatedButton(
                                            onPressed: () {
                                              _goToProfileScreen(context,
                                                  firebaseAuth:
                                                      bloc.firebaseAuth);
                                            },
                                            child:
                                                Text(intl.profileButtonLabel)),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                            onPressed: () {
                                              _logout(bloc);
                                            },
                                            child: Text(intl.logoutButtonLabel))
                                      ],
                                    ],
                                  )),
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  BusyIndicator(busy: busyStream)
                ],
              ));
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

  void _goToProfileScreen(BuildContext context,
      {required FirebaseAuth firebaseAuth}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => authProfileScreen(firebaseAuth: firebaseAuth)));
  }

  void _goToLoginScreen(BuildContext context,
      {required FirebaseAuth firebaseAuth}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => authLoginScreen(firebaseAuth: firebaseAuth)));
  }
}

/// Auth screen
Widget authScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
    blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
    child: const AuthScreen());
