import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/src/widget/auth_ui_widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Auth profile screen: account details and logout.
///
/// Pops once the user is signed out.
class AuthProfileScreen extends StatefulWidget {
  /// ui auth service (used for navigation)
  final FirebaseUiAuthService uiAuthService;

  /// Auth profile screen
  const AuthProfileScreen({
    super.key,
    this.uiAuthService = firebaseUiAuthServiceBasic,
  });

  @override
  State<AuthProfileScreen> createState() => _AuthProfileScreenState();
}

class _AuthProfileScreenState extends AutoDisposeBaseState<AuthProfileScreen>
    with AutoDisposedBusyScreenStateMixin<AuthProfileScreen> {
  @override
  void initState() {
    super.initState();

    scheduleMicrotask(() async {
      if (mounted) {
        var bloc = BlocProvider.of<AuthScreenBloc>(context);
        await for (var authState in bloc.state) {
          if (!authState.signedIn) {
            if (mounted) {
              Navigator.of(context).pop(null);
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
        var userState = snapshot.data;
        var user = userState?.user;
        if (userState == null) {
          return AuthUiScaffold(
            title: intl.profileTitle,
            children: const [
              SizedBox(height: 80),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }
        if (user == null) {
          return AuthUiScaffold(title: intl.profileTitle, children: const []);
        }
        return AuthUiScaffold(
          title: intl.profileTitle,
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
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        widget.uiAuthService.emailVerificationScreen(
                          firebaseAuth: bloc.firebaseAuth,
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
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
          print(st);
        }
      }
    });
  }
}

/// Auth profile screen
Widget authProfileScreen({
  FirebaseAuth? firebaseAuth,
  FirebaseUiAuthService uiAuthService = firebaseUiAuthServiceBasic,
}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: AuthProfileScreen(uiAuthService: uiAuthService),
);
