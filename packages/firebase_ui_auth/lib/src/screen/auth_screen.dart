import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_app_flutter_widget/view/body_container.dart';
import 'package:tekartik_app_flutter_widget/view/body_h_padding.dart';
import 'package:tekartik_app_flutter_widget/view/busy_indicator.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_common_utils/string_utils.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Auth screen
class AuthScreen extends StatefulWidget {
  /// ui auth service
  final FirebaseUiAuthService uiAuthService;

  /// Auth screen
  const AuthScreen({
    super.key,
    this.uiAuthService = firebaseUiAuthServiceBasic,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends AutoDisposeBaseState<AuthScreen>
    with AutoDisposedBusyScreenStateMixin<AuthScreen> {
  late final _showUserId = audiAddBehaviorSubject(
    BehaviorSubject.seeded(false),
  );

  FirebaseUiAuthService get uiAuthService => widget.uiAuthService;
  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    var intl = appIntl(context);
    return ValueStreamBuilder(
      stream: bloc.state,
      builder: (context, snapshot) {
        var state = snapshot.data;
        var email = state?.user?.email?.trimmedNonEmpty();
        var displayName = state?.user?.displayName?.trimmedNonEmpty();
        var uid = state?.user?.uid;
        return Scaffold(
          appBar: AppBar(title: Text(intl.authTitle)),
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.person),
                                      onTap: () {
                                        _showUserId.add(!_showUserId.value);
                                      },
                                      title: Text(
                                        intl.profileLoggedInAs(
                                          displayName ?? email ?? '<null>',
                                        ),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                      subtitle:
                                          (displayName != null && email != null)
                                              ? Text(email)
                                              : null,
                                    ),
                                    BehaviorSubjectBuilder(
                                      subject: _showUserId,
                                      builder: (_, snapshot) {
                                        return snapshot.data!
                                            ? ListTile(
                                              leading: const Icon(Icons.info),
                                              title: Text(intl.authUserIdLabel),
                                              subtitle: Text(uid!),
                                              onTap: () {
                                                Clipboard.setData(
                                                  ClipboardData(text: uid),
                                                );
                                                muiSnack(
                                                  context,
                                                  intl.authUserIdCopiedToClipboard,
                                                );
                                              },
                                            )
                                            : const SizedBox();
                                      },
                                    ),
                                    if (email != null)
                                      BehaviorSubjectBuilder(
                                        subject: _showUserId,
                                        builder: (_, snapshot) {
                                          return snapshot.data!
                                              ? ListTile(
                                                leading: const Icon(
                                                  Icons.alternate_email,
                                                ),
                                                title: Text(
                                                  intl.authUserEmailLabel,
                                                ),
                                                subtitle: Text(email),
                                                onTap: () {
                                                  Clipboard.setData(
                                                    ClipboardData(text: email),
                                                  );
                                                  muiSnack(
                                                    context,
                                                    intl.authUserEmailCopiedToClipboard,
                                                  );
                                                },
                                              )
                                              : const SizedBox();
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            BodyHPadding(
                              child: IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(width: 160),
                                    if (!state.signedIn)
                                      ElevatedButton(
                                        onPressed: () {
                                          _goToLoginScreen(
                                            context,
                                            firebaseAuth: bloc.firebaseAuth,
                                          );
                                        },
                                        child: Text(intl.loginButtonLabel),
                                      ),
                                    const SizedBox(width: 160, height: 16),
                                    if (state.signedIn) ...[
                                      ElevatedButton(
                                        onPressed: () {
                                          _goToProfileScreen(
                                            context,
                                            firebaseAuth: bloc.firebaseAuth,
                                          );
                                        },
                                        child: Text(intl.profileButtonLabel),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          _logout(bloc);
                                        },
                                        child: Text(intl.logoutButtonLabel),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              BusyIndicator(busy: busyStream),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout(AuthScreenBloc bloc) async {
    await busyAction(() async {
      try {
        await bloc.signOut();
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

  void _goToProfileScreen(
    BuildContext context, {
    required FirebaseAuth firebaseAuth,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => uiAuthService.profileScreen(firebaseAuth: firebaseAuth),
      ),
    );
  }

  void _goToLoginScreen(
    BuildContext context, {
    required FirebaseAuth firebaseAuth,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => uiAuthService.loginScreen(firebaseAuth: firebaseAuth),
      ),
    );
  }
}

/// Auth screen
Widget authScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: const AuthScreen(),
);
