import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tekartik_app_flutter_widget/mini_ui.dart';
import 'package:tekartik_common_utils/string_utils.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';

import 'auth_ui_theme.dart';
import 'auth_ui_widgets.dart';

/// Card listing the account details of a signed-in user: user id, email,
/// verification status and sign-in provider.
class AuthAccountDetailsSection extends StatelessWidget {
  /// The user.
  final User user;

  /// Called when the user taps the (unverified) status row.
  final VoidCallback? onVerifyEmail;

  /// Account details.
  const AuthAccountDetailsSection({
    super.key,
    required this.user,
    this.onVerifyEmail,
  });

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    var intl = appIntl(context);
    var email = user.email?.trimmedNonEmpty();
    var verified = user.emailVerified;
    var providerId = user.providerId?.trimmedNonEmpty();
    var providerText = user.isAnonymous
        ? intl.authAnonymousUser
        : (providerId ?? 'password');
    return AuthUiCard(
      children: [
        AuthUiDetailRow(
          icon: Icons.fingerprint,
          color: ui.primary,
          softColor: ui.primarySoft,
          label: intl.authUserIdLabel,
          value: user.uid,
          monospace: true,
          trailing: IconButton(
            icon: Icon(Icons.copy_outlined, color: ui.muted),
            tooltip: intl.copyTooltip,
            onPressed: () =>
                _copy(context, user.uid, intl.authUserIdCopiedToClipboard),
          ),
          onTap: () =>
              _copy(context, user.uid, intl.authUserIdCopiedToClipboard),
        ),
        if (email != null)
          AuthUiDetailRow(
            icon: Icons.mail_outline,
            color: ui.info,
            softColor: ui.infoSoft,
            label: intl.authUserEmailLabel,
            value: email,
            trailing: AuthUiBadge(
              intl.authPrimaryBadge,
              color: ui.neutral,
              softColor: ui.neutralSoft,
            ),
            onTap: () =>
                _copy(context, email, intl.authUserEmailCopiedToClipboard),
          ),
        AuthUiDetailRow(
          icon: verified ? Icons.check_circle_outline : Icons.error_outline,
          color: verified ? ui.success : ui.warning,
          softColor: verified ? ui.successSoft : ui.warningSoft,
          label: intl.authSecurityStatusLabel,
          value: verified
              ? intl.emailVerifiedMessage
              : intl.emailNotVerifiedMessage,
          trailing: AuthUiBadge(
            verified ? intl.authConfirmedBadge : intl.authPendingBadge,
            color: verified ? ui.success : ui.warning,
            softColor: verified ? ui.successSoft : ui.warningSoft,
          ),
          onTap: verified ? null : onVerifyEmail,
        ),
        AuthUiDetailRow(
          icon: Icons.shield_outlined,
          color: ui.warning,
          softColor: ui.warningSoft,
          label: intl.authSessionProviderLabel,
          value: providerText,
          trailing: providerId != null
              ? AuthUiBadge(
                  providerId.toUpperCase(),
                  color: ui.neutral,
                  softColor: ui.neutralSoft,
                )
              : null,
        ),
      ],
    );
  }

  Future<void> _copy(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      await muiSnack(context, message);
    }
  }
}
