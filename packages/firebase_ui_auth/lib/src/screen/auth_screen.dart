import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/src/widget/auth_ui_widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Auth screen: entry point of the authentication flow.
///
/// Signed out: welcome page with "Sign in" (and "Create account" when
/// [FirebaseUiAuthOptions.registerEnabled]).
///
/// Signed in: user header, account details, preferences and logout.
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
  FirebaseUiAuthService get uiAuthService => widget.uiAuthService;

  FirebaseUiAuthOptions get options => uiAuthService.options;

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    var intl = appIntl(context);
    var ui = AuthUiTheme.of(context);
    return ValueStreamBuilder(
      stream: bloc.state,
      builder: (context, snapshot) {
        var state = snapshot.data;
        var user = state?.user;
        if (state == null) {
          return AuthUiScaffold(
            title: intl.authTitle,
            children: const [
              SizedBox(height: 80),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
        if (user == null) {
          return _buildSignedOut(context, bloc, intl);
        }
        return _buildSignedIn(context, bloc, user, intl, ui);
      },
    );
  }

  Widget _buildSignedOut(
    BuildContext context,
    AuthScreenBloc bloc,
    FirebaseUiAuthServiceBasicLocalizations intl,
  ) {
    return AuthUiScaffold(
      title: intl.authTitle,
      busy: busyStream,
      children: [
        const SizedBox(height: 24),
        const AuthUiHeroIcon(Icons.lock_person_outlined),
        const SizedBox(height: 24),
        AuthUiHeadline(
          title: intl.authWelcomeHeadline,
          subtitle: intl.authWelcomeSubtitle,
        ),
        const SizedBox(height: 32),
        AuthUiPrimaryButton(
          label: intl.loginButtonLabel,
          icon: Icons.arrow_forward,
          onPressed: () {
            _goToLoginScreen(context, firebaseAuth: bloc.firebaseAuth);
          },
        ),
        if (options.registerEnabled) ...[
          const SizedBox(height: 12),
          AuthUiOutlinedButton(
            label: intl.authCreateAccountButtonLabel,
            icon: Icons.person_add_alt_outlined,
            onPressed: () {
              _goToRegisterScreen(context, firebaseAuth: bloc.firebaseAuth);
            },
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSignedIn(
    BuildContext context,
    AuthScreenBloc bloc,
    User user,
    FirebaseUiAuthServiceBasicLocalizations intl,
    AuthUiTheme ui,
  ) {
    var showEmailVerification = !user.emailVerified && !user.isAnonymous;
    return AuthUiScaffold(
      title: intl.authTitle,
      busy: busyStream,
      bottom: AuthUiTintedButton(
        label: intl.logoutButtonLabel,
        icon: Icons.logout,
        color: ui.danger,
        softColor: ui.dangerSoft,
        onPressed: () {
          _logout(bloc);
        },
      ),
      children: [
        const SizedBox(height: 8),
        AuthUserHeaderCard(user: user),
        AuthUiSectionHeader(intl.authAccountDetailsSection),
        AuthAccountDetailsSection(
          user: user,
          onVerifyEmail: () {
            _goToEmailVerificationScreen(
              context,
              firebaseAuth: bloc.firebaseAuth,
            );
          },
        ),
        AuthUiSectionHeader(intl.authPreferencesSection),
        AuthUiCard(
          children: [
            AuthUiNavRow(
              icon: Icons.person_outline,
              title: intl.profileButtonLabel,
              subtitle: intl.profileRowSubtitle,
              onTap: () {
                _goToProfileScreen(context, firebaseAuth: bloc.firebaseAuth);
              },
            ),
            if (showEmailVerification)
              AuthUiNavRow(
                icon: Icons.mark_email_unread_outlined,
                title: intl.emailVerificationButtonLabel,
                subtitle: intl.emailVerificationRowSubtitle,
                onTap: () {
                  _goToEmailVerificationScreen(
                    context,
                    firebaseAuth: bloc.firebaseAuth,
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
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
          print(st);
        }
      }
    });
  }

  void _push(BuildContext context, Widget Function() builder) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => builder()));
  }

  void _goToProfileScreen(
    BuildContext context, {
    required FirebaseAuth firebaseAuth,
  }) {
    _push(
      context,
      () => uiAuthService.profileScreen(firebaseAuth: firebaseAuth),
    );
  }

  void _goToEmailVerificationScreen(
    BuildContext context, {
    required FirebaseAuth firebaseAuth,
  }) {
    _push(
      context,
      () => uiAuthService.emailVerificationScreen(firebaseAuth: firebaseAuth),
    );
  }

  void _goToLoginScreen(
    BuildContext context, {
    required FirebaseAuth firebaseAuth,
  }) {
    _push(context, () => uiAuthService.loginScreen(firebaseAuth: firebaseAuth));
  }

  void _goToRegisterScreen(
    BuildContext context, {
    required FirebaseAuth firebaseAuth,
  }) {
    _push(
      context,
      () => uiAuthService.registerScreen(firebaseAuth: firebaseAuth),
    );
  }
}

/// Auth screen
Widget authScreen({
  FirebaseAuth? firebaseAuth,
  FirebaseUiAuthService uiAuthService = firebaseUiAuthServiceBasic,
}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: AuthScreen(uiAuthService: uiAuthService),
);
