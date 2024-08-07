import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_flutter_widget/view/body_container.dart';
import 'package:tekartik_app_flutter_widget/view/body_h_padding.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth/auth.dart';

import 'auth_screen_bloc.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    return ValueStreamBuilder(
        stream: bloc.state,
        builder: (context, snapshot) {
          var state = snapshot.data;
          return Scaffold(
              appBar: AppBar(
                title: const Text('Auth'),
              ),
              body: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    if (state == null)
                      const CircularProgressIndicator()
                    else
                      BodyContainer(
                        child: Column(
                          children: [
                            IntrinsicWidth(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (state.signedIn)
                                  BodyHPadding(
                                    child: Center(
                                      child: Text(
                                          state.user?.email ?? 'Signed in',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                    ),
                                  ),
                                if (!state.signedIn)
                                  BodyHPadding(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            _goToLoginScreen(context,
                                                firebaseAuth:
                                                    bloc.firebaseAuth);
                                          },
                                          child: const Text('Login'))),
                                const SizedBox(width: 200, height: 16),
                                if (state.signedIn)
                                  BodyHPadding(
                                      child: ElevatedButton(
                                          onPressed: () {
                                            _goToProfileScreen(context,
                                                firebaseAuth:
                                                    bloc.firebaseAuth);
                                          },
                                          child: const Text('Profile')))
                              ],
                            ))
                          ],
                        ),
                      ),
                  ],
                ),
              ));
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

Widget authScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
    blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
    child: const AuthScreen());
