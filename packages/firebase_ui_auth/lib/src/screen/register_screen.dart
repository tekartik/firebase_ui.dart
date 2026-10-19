import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_ui_auth/src/screen/auth_screen_utils.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/src/widget/auth_ui_widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Auth register screen (create an account with email and password).
///
/// Pops with the signed-in [User] once the account is created. For an
/// anonymous user, with [FirebaseUiAuthOptions.linkAnonymousUser], the
/// account is linked to that user, which keeps its uid.
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

  FirebaseUiAuthOptions get options => widget.uiAuthService.options;

  /// Whether the account is linked to the current, anonymous, user.
  bool _linksAnonymousUser(AuthScreenBlocState? authState) =>
      options.linkAnonymousUser && (authState?.user?.isAnonymous ?? false);

  @override
  void initState() {
    _check();
    super.initState();

    authScreenPopWhen(
      this,
      // Not for an anonymous user: they came to get an account.
      when: (authState) => authState.hasAccount,
    );
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
        ValueStreamBuilder(
          stream: bloc.state,
          builder: (context, snapshot) => AuthUiHeadline(
            title: intl.registerHeadline,
            subtitle: _linksAnonymousUser(snapshot.data)
                ? intl.registerLinkSubtitle
                : intl.registerSubtitle,
          ),
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
        AuthUiSubjectMessageCard.error(_error),
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
    var intl = appIntl(context);
    await authSubmit(
      check: _check,
      error: _error,
      errorMessage: intl.registerGenericError,
      errorMessageOf: (e) =>
          authIsEmailInUseError(e) ? intl.registerEmailInUseError : null,
      action: () async {
        var email = emailController.text.trim();
        // Trimmed since the first version (the login screen trims too).
        var password = passwordController.text.trim();
        if (_linksAnonymousUser(bloc.state.valueOrNull)) {
          await bloc.linkWithEmailAndPassword(email: email, password: password);
        } else {
          await bloc.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
    );
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
