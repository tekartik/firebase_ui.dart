import 'package:flutter/material.dart';
import 'package:tekartik_common_utils/string_utils.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/src/utils/app_intl.dart';

import 'auth_ui_theme.dart';
import 'auth_ui_widgets.dart';

/// Initials displayed in the user avatar (2 letters max).
String authUserInitials({String? displayName, String? email}) {
  var name = displayName?.trimmedNonEmpty();
  if (name != null) {
    var words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
  var local = email?.trimmedNonEmpty()?.split('@').first;
  if (local != null && local.isNotEmpty) {
    return local.substring(0, local.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '?';
}

/// Card showing the avatar, name, verified badge, email and session status of
/// a signed-in user.
class AuthUserHeaderCard extends StatelessWidget {
  /// The user.
  final User user;

  /// User header card.
  const AuthUserHeaderCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    var intl = appIntl(context);
    var email = user.email?.trimmedNonEmpty();
    var displayName = user.displayName?.trimmedNonEmpty();
    var name =
        displayName ??
        email?.split('@').first ??
        (user.isAnonymous ? intl.authAnonymousUser : user.uid);
    var initials = authUserInitials(displayName: displayName, email: email);
    var textTheme = Theme.of(context).textTheme;
    return AuthUiCard(
      dividers: false,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: ui.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: ui.onPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: ui.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: ui.card, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          name,
                          style: textTheme.titleLarge?.copyWith(
                            color: ui.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (user.emailVerified)
                          AuthUiBadge(
                            intl.authVerifiedBadge,
                            color: ui.success,
                            softColor: ui.successSoft,
                            icon: Icons.verified_user_outlined,
                          ),
                      ],
                    ),
                    if (email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: ui.subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: ui.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          intl.authActiveSession,
                          style: ui.rowLabelStyle.copyWith(color: ui.success),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
