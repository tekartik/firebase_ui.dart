import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_app_url_launcher_flutter/web_launch_uri.dart';
import 'package:tekartik_firebase_auth_rest/auth_rest.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/src/widget/auth_ui_widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// debug username
String? gDebugUsername;

/// debug password
String? gDebugPassword;

/// Auth login screen (email and password).
///
/// Pops with the signed-in [User] once the sign-in succeeds.
class AuthLoginScreen extends StatefulWidget {
  /// ui auth service (used for navigation and options)
  final FirebaseUiAuthService uiAuthService;

  /// Auth login screen
  const AuthLoginScreen({
    super.key,
    this.uiAuthService = firebaseUiAuthServiceBasic,
  });

  @override
  State<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends AutoDisposeBaseState<AuthLoginScreen>
    with AutoDisposedBusyScreenStateMixin<AuthLoginScreen> {
  late final usernameController = audiAddTextEditingController(
    TextEditingController(text: gDebugUsername),
  );
  late final passwordController = audiAddTextEditingController(
    TextEditingController(text: gDebugPassword),
  );
  late final _loginEnabled = audiAddBehaviorSubject(
    BehaviorSubject<bool>.seeded(false),
  );
  late final _error = audiAddBehaviorSubject(BehaviorSubject<String?>());

  FirebaseUiAuthService get uiAuthService => widget.uiAuthService;

  FirebaseUiAuthOptions get options => uiAuthService.options;

  @override
  void initState() {
    _checkLoginEnabled();
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

  bool _checkLoginEnabled() {
    var loginEnabled =
        usernameController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        !busy;
    _loginEnabled.value = loginEnabled;
    return loginEnabled;
  }

  GoogleRestAuthProvider? _findGoogleRestProvider(FirebaseAuth auth) {
    if (auth is FirebaseAuthRest) {
      for (var provider in auth.providers) {
        if (provider is GoogleRestAuthProvider) {
          return provider;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    var intl = appIntl(context);
    var ui = AuthUiTheme.of(context);
    var googleProvider = _findGoogleRestProvider(bloc.firebaseAuth);

    return ValueStreamBuilder(
      stream: bloc.state,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return AuthUiScaffold(
            title: intl.loginTitle,
            children: const [
              SizedBox(height: 80),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
        return AuthUiScaffold(
          title: intl.loginTitle,
          busy: busyStream,
          children: [
            const SizedBox(height: 16),
            const AuthUiHeroIcon(Icons.login),
            const SizedBox(height: 24),
            AuthUiHeadline(
              title: intl.loginHeadline,
              subtitle: intl.loginSubtitle,
            ),
            const SizedBox(height: 28),
            AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthUiTextField(
                    controller: usernameController,
                    label: intl.loginUserLabel,
                    hint: intl.loginUserHint,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    onChanged: (_) {
                      _error.add(null);
                      _checkLoginEnabled();
                    },
                  ),
                  const SizedBox(height: 20),
                  AuthUiPasswordField(
                    controller: passwordController,
                    label: intl.loginPasswordLabel,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    showTooltip: intl.passwordShowTooltip,
                    hideTooltip: intl.passwordHideTooltip,
                    onChanged: (_) {
                      _error.add(null);
                      _checkLoginEnabled();
                    },
                    onSubmitted: (_) {
                      _login(context, bloc);
                    },
                  ),
                ],
              ),
            ),
            if (options.lostPasswordEnabled)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AuthUiLinkButton(
                    label: intl.loginForgotPasswordLink,
                    onPressed: () {
                      _goToLostPasswordScreen(context, bloc);
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),
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
              stream: _loginEnabled,
              builder: (context, snapshot) {
                var enabled = snapshot.data ?? false;
                return AuthUiPrimaryButton(
                  label: intl.loginButtonLabel,
                  icon: Icons.arrow_forward,
                  onPressed: enabled
                      ? () {
                          _login(context, bloc);
                        }
                      : null,
                );
              },
            ),
            if (googleProvider != null) ...[
              const SizedBox(height: 28),
              AuthUiOrDivider(intl.loginOrContinueWith),
              const SizedBox(height: 20),
              AuthUiOutlinedButton(
                label: intl.googleButtonLabel,
                leading: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ui.primary,
                  ),
                ),
                onPressed: () {
                  _signInWithGoogle(context, bloc, googleProvider);
                },
              ),
            ],
            if (options.registerEnabled) ...[
              const SizedBox(height: 32),
              AuthUiFooterPrompt(
                text: intl.loginNoAccountText,
                linkLabel: intl.loginSignUpLink,
                onTap: () {
                  _goToRegisterScreen(context, bloc);
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _goToLostPasswordScreen(BuildContext context, AuthScreenBloc bloc) {
    var email = usernameController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => uiAuthService.lostPasswordScreen(
          firebaseAuth: bloc.firebaseAuth,
          email: email.isEmpty ? null : email,
        ),
      ),
    );
  }

  void _goToRegisterScreen(BuildContext context, AuthScreenBloc bloc) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            uiAuthService.registerScreen(firebaseAuth: bloc.firebaseAuth),
      ),
    );
  }

  Future<void> _signInWithGoogle(
    BuildContext context,
    AuthScreenBloc bloc,
    GoogleRestAuthProvider provider,
  ) async {
    var intl = appIntl(context);
    provider.userPrompt = (uri) async {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(intl.signInWithGoogleButtonLabel),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(intl.googleSignInLinkMessage),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      webLaunchUri(Uri.parse(uri));
                    },
                    child: Text(
                      uri,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: uri));
                  },
                  child: Text(intl.copyLinkButtonLabel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(intl.doneButtonLabel),
                ),
              ],
            );
          },
        );
      }
    };
    await busyAction(() async {
      try {
        await bloc.firebaseAuth.signIn(provider);
      } catch (e, st) {
        if (kDebugMode) {
          print('Error $e');
          print(st);
        }
        _error.add(intl.loginGenericError);
      }
    });
  }

  Future<void> _login(BuildContext context, AuthScreenBloc bloc) async {
    if (_checkLoginEnabled()) {
      var intl = appIntl(context);
      await busyAction(() async {
        try {
          var username = usernameController.text.trim();
          var password = passwordController.text.trim();
          _error.add(null);
          await bloc.signInWithEmailAndPassword(
            email: username,
            password: password,
          );

          await Future<void>.delayed(const Duration(milliseconds: 300));
        } catch (e, st) {
          if (kDebugMode) {
            print('Error $e');
            print(st);
          }
          _error.add(intl.loginGenericError);
        } finally {
          _checkLoginEnabled();
        }
      });
    }
  }
}

/// Auth login screen
Widget authLoginScreen({
  FirebaseAuth? firebaseAuth,
  FirebaseUiAuthService uiAuthService = firebaseUiAuthServiceBasic,
}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: AuthLoginScreen(uiAuthService: uiAuthService),
);
