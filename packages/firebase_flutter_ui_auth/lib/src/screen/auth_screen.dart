import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_flutter_widget/view/body_container.dart';
import 'package:tekartik_app_flutter_widget/view/body_h_padding.dart';
import 'package:tekartik_app_flutter_widget/view/busy_indicator.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_flutter_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';

/// Auth screen
class AuthFlutterScreen extends StatefulWidget {
  /// Auth screen
  const AuthFlutterScreen({super.key});

  @override
  State<AuthFlutterScreen> createState() => _AuthFlutterScreenState();
}

class _AuthFlutterScreenState extends AutoDisposeBaseState<AuthFlutterScreen>
    with AutoDisposedBusyScreenStateMixin<AuthFlutterScreen> {
  late final _showUserId =
      audiAddBehaviorSubject(BehaviorSubject.seeded(false));
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
                                BodyHPadding(
                                  child: IntrinsicWidth(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (state.signedIn)
                                        GestureDetector(
                                          onLongPress: () {
                                            _showUserId.add(!_showUserId.value);
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  intl.profileLoggedInAs(state
                                                          .user!.email ??
                                                      state.user!.displayName ??
                                                      'user'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium),
                                              BehaviorSubjectBuilder(
                                                  subject: _showUserId,
                                                  builder: (_, snapshot) {
                                                    return snapshot.data!
                                                        ? ListTile(
                                                            title: const Text(
                                                                'User id'),
                                                            subtitle: Text(state
                                                                .user!.uid),
                                                            onTap: () {
                                                              Clipboard.setData(
                                                                  ClipboardData(
                                                                      text: state
                                                                          .user!
                                                                          .uid));
                                                              muiSnack(context,
                                                                  'User id copied to clipboard');
                                                            },
                                                          )
                                                        : const SizedBox();
                                                  })
                                            ],
                                          ),
                                        ),
                                      if (!state.signedIn)
                                        ElevatedButton(
                                            onPressed: () {
                                              _goToLoginScreen(context,
                                                  firebaseAuth:
                                                      bloc.firebaseAuth);
                                            },
                                            child: Text(intl.loginButtonLabel)),
                                      const SizedBox(width: 160, height: 16),
                                      if (state.signedIn) ...[
                                        BodyHPadding(
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  _goToProfileScreen(context,
                                                      firebaseAuth:
                                                          bloc.firebaseAuth);
                                                },
                                                child: Text(
                                                    intl.profileButtonLabel))),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                            onPressed: () {
                                              _logout(bloc);
                                            },
                                            child: Text(intl.logoutButtonLabel))
                                      ]
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
        //await bloc.firebaseAuth.signOut();
        await Future<void>.delayed(const Duration(milliseconds: 1300));
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
        builder: (_) => authFlutterProfileScreen(firebaseAuth: firebaseAuth)));
  }

  void _goToLoginScreen(BuildContext context,
      {required FirebaseAuth firebaseAuth}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => authFlutterLoginScreen(firebaseAuth: firebaseAuth)));
  }
}

/// Auth screen
Widget authFlutterScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
    blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
    child: const AuthFlutterScreen());
