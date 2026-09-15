import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_common_utils/string_utils.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/src/widget/auth_ui_widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Email verification screen: sends a verification email to the current user
/// and lets the user check the verification status.
///
/// Pops once the email is verified or the user is signed out.
class AuthEmailVerificationScreen extends StatefulWidget {
  /// ui auth service (used for options)
  final FirebaseUiAuthService uiAuthService;

  /// Email verification screen
  const AuthEmailVerificationScreen({
    super.key,
    this.uiAuthService = firebaseUiAuthServiceBasic,
  });

  @override
  State<AuthEmailVerificationScreen> createState() =>
      _AuthEmailVerificationScreenState();
}

class _AuthEmailVerificationScreenState
    extends AutoDisposeBaseState<AuthEmailVerificationScreen>
    with AutoDisposedBusyScreenStateMixin<AuthEmailVerificationScreen> {
  late final _info = audiAddBehaviorSubject(BehaviorSubject<String?>());
  late final _error = audiAddBehaviorSubject(BehaviorSubject<String?>());

  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      if (mounted) {
        var bloc = BlocProvider.of<AuthScreenBloc>(context);
        await for (var authState in bloc.state) {
          var user = authState.user;
          if (user == null || user.emailVerified) {
            if (mounted) {
              Navigator.of(context).pop(user);
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
    var ui = AuthUiTheme.of(context);
    return ValueStreamBuilder(
      stream: bloc.state,
      builder: (context, snapshot) {
        var user = snapshot.data?.user;
        if (user == null) {
          return AuthUiScaffold(
            title: intl.emailVerificationTitle,
            children: const [
              SizedBox(height: 80),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
        var email = user.email?.trimmedNonEmpty() ?? '';
        return AuthUiScaffold(
          title: intl.emailVerificationTitle,
          busy: busyStream,
          children: [
            const SizedBox(height: 16),
            const AuthUiHeroIcon(Icons.mark_email_unread_outlined),
            const SizedBox(height: 24),
            AuthUiHeadline(
              title: intl.emailVerificationHeadline,
              subtitle: intl.emailVerificationSubtitle(email),
            ),
            const SizedBox(height: 28),
            BehaviorSubjectBuilder(
              subject: _info,
              builder: (_, snapshot) {
                var info = snapshot.data;
                if (info == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AuthUiMessageCard(
                    text: info,
                    icon: Icons.check_circle_outline,
                    color: ui.success,
                    softColor: ui.successSoft,
                  ),
                );
              },
            ),
            BehaviorSubjectBuilder(
              subject: _error,
              builder: (_, snapshot) {
                var error = snapshot.data;
                if (error == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AuthUiMessageCard(
                    text: error,
                    icon: Icons.error_outline,
                    color: ui.danger,
                    softColor: ui.dangerSoft,
                  ),
                );
              },
            ),
            AuthUiPrimaryButton(
              label: intl.emailVerificationSendButtonLabel,
              icon: Icons.send_outlined,
              onPressed: () {
                _send(context, bloc);
              },
            ),
            const SizedBox(height: 12),
            AuthUiOutlinedButton(
              label: intl.emailVerificationCheckButtonLabel,
              icon: Icons.refresh,
              onPressed: () {
                _check(context, bloc);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Future<void> _send(BuildContext context, AuthScreenBloc bloc) async {
    var intl = appIntl(context);
    await busyAction(() async {
      try {
        _error.add(null);
        await bloc.sendEmailVerification();
        _info.add(intl.emailVerificationSentMessage);
      } catch (e, st) {
        if (kDebugMode) {
          print('Error $e');
          print(st);
        }
        _info.add(null);
        _error.add(intl.emailVerificationGenericError);
      }
    });
  }

  Future<void> _check(BuildContext context, AuthScreenBloc bloc) async {
    var intl = appIntl(context);
    await busyAction(() async {
      try {
        _error.add(null);
        var user = await bloc.reloadCurrentUser();
        if (user?.emailVerified ?? false) {
          // The state listener pops the screen
          _info.add(intl.emailVerifiedMessage);
        } else {
          _info.add(null);
          _error.add(intl.emailVerificationNotYetVerifiedMessage);
        }
      } catch (e, st) {
        if (kDebugMode) {
          print('Error $e');
          print(st);
        }
        _info.add(null);
        _error.add(intl.emailVerificationNotYetVerifiedMessage);
      }
    });
  }
}

/// Auth email verification screen
Widget authEmailVerificationScreen({
  FirebaseAuth? firebaseAuth,
  FirebaseUiAuthService uiAuthService = firebaseUiAuthServiceBasic,
}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: AuthEmailVerificationScreen(uiAuthService: uiAuthService),
);
