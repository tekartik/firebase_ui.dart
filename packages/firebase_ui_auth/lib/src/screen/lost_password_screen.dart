import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/src/widget/auth_ui_widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Lost password screen: sends a password reset email.
class AuthLostPasswordScreen extends StatefulWidget {
  /// ui auth service (used for options)
  final FirebaseUiAuthService uiAuthService;

  /// Initial email.
  final String? email;

  /// Lost password screen
  const AuthLostPasswordScreen({
    super.key,
    this.uiAuthService = firebaseUiAuthServiceBasic,
    this.email,
  });

  @override
  State<AuthLostPasswordScreen> createState() => _AuthLostPasswordScreenState();
}

class _AuthLostPasswordScreenState
    extends AutoDisposeBaseState<AuthLostPasswordScreen>
    with AutoDisposedBusyScreenStateMixin<AuthLostPasswordScreen> {
  late final emailController = audiAddTextEditingController(
    TextEditingController(text: widget.email),
  );
  late final _sendEnabled = audiAddBehaviorSubject(
    BehaviorSubject<bool>.seeded(false),
  );
  late final _error = audiAddBehaviorSubject(BehaviorSubject<String?>());

  /// Email the reset link was sent to (null until sent).
  late final _sentEmail = audiAddBehaviorSubject(BehaviorSubject<String?>());

  @override
  void initState() {
    _check();
    super.initState();
  }

  bool _check() {
    var enabled = emailController.text.trim().isNotEmpty && !busy;
    _sendEnabled.value = enabled;
    return enabled;
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    var intl = appIntl(context);
    var ui = AuthUiTheme.of(context);

    return BehaviorSubjectBuilder(
      subject: _sentEmail,
      builder: (context, snapshot) {
        var sentEmail = snapshot.data;
        if (sentEmail != null) {
          return AuthUiScaffold(
            title: intl.lostPasswordTitle,
            children: [
              const SizedBox(height: 16),
              const AuthUiHeroIcon(Icons.mark_email_read_outlined),
              const SizedBox(height: 24),
              AuthUiHeadline(
                title: intl.lostPasswordSentTitle,
                subtitle: intl.lostPasswordSentMessage(sentEmail),
              ),
              const SizedBox(height: 32),
              AuthUiPrimaryButton(
                label: intl.lostPasswordBackToSignInLink,
                leadingIcon: Icons.arrow_back,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        }
        return AuthUiScaffold(
          title: intl.lostPasswordTitle,
          busy: busyStream,
          children: [
            const SizedBox(height: 16),
            const AuthUiHeroIcon(Icons.lock_reset),
            const SizedBox(height: 24),
            AuthUiHeadline(
              title: intl.lostPasswordHeadline,
              subtitle: intl.lostPasswordSubtitle,
            ),
            const SizedBox(height: 28),
            AuthUiTextField(
              controller: emailController,
              label: intl.loginUserLabel,
              hint: intl.loginUserHint,
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              autofocus: widget.email == null,
              onChanged: (_) {
                _error.add(null);
                _check();
              },
              onSubmitted: (_) {
                _send(context, bloc);
              },
            ),
            const SizedBox(height: 24),
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
            ValueStreamBuilder(
              stream: _sendEnabled,
              builder: (context, snapshot) {
                var enabled = snapshot.data ?? false;
                return AuthUiPrimaryButton(
                  label: intl.lostPasswordButtonLabel,
                  icon: Icons.send_outlined,
                  onPressed: enabled
                      ? () {
                          _send(context, bloc);
                        }
                      : null,
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: AuthUiLinkButton(
                label: intl.lostPasswordBackToSignInLink,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Future<void> _send(BuildContext context, AuthScreenBloc bloc) async {
    if (_check()) {
      var intl = appIntl(context);
      await busyAction(() async {
        var email = emailController.text.trim();
        try {
          _error.add(null);
          await bloc.sendPasswordResetEmail(email: email);
          _sentEmail.add(email);
        } catch (e, st) {
          if (kDebugMode) {
            print('Error $e');
            print(st);
          }
          _error.add(intl.lostPasswordGenericError);
        } finally {
          _check();
        }
      });
    }
  }
}

/// Auth lost password screen
Widget authLostPasswordScreen({
  FirebaseAuth? firebaseAuth,
  FirebaseUiAuthService uiAuthService = firebaseUiAuthServiceBasic,
  String? email,
}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: AuthLostPasswordScreen(uiAuthService: uiAuthService, email: email),
);
