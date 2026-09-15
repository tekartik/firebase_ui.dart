import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/src/widget/auth_ui_widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Auth register screen (create an account with email and password).
///
/// Pops with the signed-in [User] once the account is created.
class AuthRegisterScreen extends StatefulWidget {
  /// ui auth service (used for options)
  final FirebaseUiAuthService uiAuthService;

  /// Auth register screen
  const AuthRegisterScreen({
    super.key,
    this.uiAuthService = firebaseUiAuthServiceBasic,
  });

  @override
  State<AuthRegisterScreen> createState() => _AuthRegisterScreenState();
}

class _AuthRegisterScreenState extends AutoDisposeBaseState<AuthRegisterScreen>
    with AutoDisposedBusyScreenStateMixin<AuthRegisterScreen> {
  late final emailController = audiAddTextEditingController(
    TextEditingController(),
  );
  late final passwordController = audiAddTextEditingController(
    TextEditingController(),
  );
  late final passwordConfirmController = audiAddTextEditingController(
    TextEditingController(),
  );
  late final _registerEnabled = audiAddBehaviorSubject(
    BehaviorSubject<bool>.seeded(false),
  );
  late final _mismatch = audiAddBehaviorSubject(
    BehaviorSubject<bool>.seeded(false),
  );
  late final _error = audiAddBehaviorSubject(BehaviorSubject<String?>());

  @override
  void initState() {
    _check();
    super.initState();

    scheduleMicrotask(() async {
      if (mounted) {
        var bloc = BlocProvider.of<AuthScreenBloc>(context);
        await for (var authState in bloc.state) {
          if (authState.signedIn) {
            if (mounted) {
              Navigator.of(context).pop(authState.user);
            }
            return;
          }
        }
        return;
      }
    });
  }

  bool _check() {
    var email = emailController.text.trim();
    var password = passwordController.text.trim();
    var confirm = passwordConfirmController.text.trim();
    var mismatch = confirm.isNotEmpty && confirm != password;
    _mismatch.value = mismatch;
    var enabled =
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirm.isNotEmpty &&
        !mismatch &&
        !busy;
    _registerEnabled.value = enabled;
    return enabled;
  }

  void _onChanged(String _) {
    _error.add(null);
    _check();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    var intl = appIntl(context);
    var ui = AuthUiTheme.of(context);

    return AuthUiScaffold(
      title: intl.registerTitle,
      busy: busyStream,
      children: [
        const SizedBox(height: 16),
        const AuthUiHeroIcon(Icons.person_add_alt_outlined),
        const SizedBox(height: 24),
        AuthUiHeadline(
          title: intl.registerHeadline,
          subtitle: intl.registerSubtitle,
        ),
        const SizedBox(height: 28),
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthUiTextField(
                controller: emailController,
                label: intl.loginUserLabel,
                hint: intl.loginUserHint,
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onChanged: _onChanged,
              ),
              const SizedBox(height: 20),
              AuthUiPasswordField(
                controller: passwordController,
                label: intl.loginPasswordLabel,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                showTooltip: intl.passwordShowTooltip,
                hideTooltip: intl.passwordHideTooltip,
                onChanged: _onChanged,
              ),
              const SizedBox(height: 20),
              AuthUiPasswordField(
                controller: passwordConfirmController,
                label: intl.registerPasswordConfirmLabel,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                showTooltip: intl.passwordShowTooltip,
                hideTooltip: intl.passwordHideTooltip,
                onChanged: _onChanged,
                onSubmitted: (_) {
                  _register(context, bloc);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BehaviorSubjectBuilder(
          subject: _mismatch,
          builder: (_, snapshot) {
            if (snapshot.data != true) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AuthUiMessageCard(
                text: intl.registerPasswordMismatchError,
                icon: Icons.warning_amber_outlined,
                color: ui.warning,
                softColor: ui.warningSoft,
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
        ValueStreamBuilder(
          stream: _registerEnabled,
          builder: (context, snapshot) {
            var enabled = snapshot.data ?? false;
            return AuthUiPrimaryButton(
              label: intl.registerButtonLabel,
              icon: Icons.arrow_forward,
              onPressed: enabled
                  ? () {
                      _register(context, bloc);
                    }
                  : null,
            );
          },
        ),
        const SizedBox(height: 32),
        AuthUiFooterPrompt(
          text: intl.registerHaveAccountText,
          linkLabel: intl.registerSignInLink,
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _register(BuildContext context, AuthScreenBloc bloc) async {
    if (_check()) {
      var intl = appIntl(context);
      await busyAction(() async {
        try {
          var email = emailController.text.trim();
          var password = passwordController.text.trim();
          _error.add(null);
          await bloc.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          await Future<void>.delayed(const Duration(milliseconds: 300));
        } catch (e, st) {
          if (kDebugMode) {
            print('Error $e');
            print(st);
          }
          _error.add(intl.registerGenericError);
        } finally {
          _check();
        }
      });
    }
  }
}

/// Auth register screen
Widget authRegisterScreen({
  FirebaseAuth? firebaseAuth,
  FirebaseUiAuthService uiAuthService = firebaseUiAuthServiceBasic,
}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: AuthRegisterScreen(uiAuthService: uiAuthService),
);
