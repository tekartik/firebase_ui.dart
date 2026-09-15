import 'package:flutter/material.dart';
import 'package:tekartik_app_flutter_widget/view/busy_indicator.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';

import 'auth_ui_theme.dart';

/// Page scaffold used by all the auth screens.
///
/// Gradient background, small caps centered title, scrollable column limited
/// to [AuthUiTheme.maxWidth] and an optional pinned [bottom] area.
class AuthUiScaffold extends StatelessWidget {
  /// App bar title (displayed in small caps).
  final String title;

  /// Scrollable content.
  final List<Widget> children;

  /// Optional pinned bottom area (buttons).
  final Widget? bottom;

  /// Optional busy stream showing a progress indicator.
  final ValueStream<bool>? busy;

  /// Scaffold.
  const AuthUiScaffold({
    super.key,
    required this.title,
    required this.children,
    this.bottom,
    this.busy,
  });

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    Widget constrained(Widget child) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AuthUiTheme.maxWidth),
        child: child,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(gradient: ui.pageGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(title.toUpperCase(), style: ui.appBarTitleStyle),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuthUiTheme.pagePadding,
                      vertical: 8,
                    ),
                    children: [
                      constrained(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ],
                  ),
                ),
                if (bottom != null)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AuthUiTheme.pagePadding,
                        8,
                        AuthUiTheme.pagePadding,
                        16,
                      ),
                      child: constrained(bottom!),
                    ),
                  ),
              ],
            ),
            if (busy != null) BusyIndicator(busy: busy!),
          ],
        ),
      ),
    );
  }
}

/// Big rounded icon with the primary gradient (screen hero).
class AuthUiHeroIcon extends StatelessWidget {
  /// Icon.
  final IconData icon;

  /// Size.
  final double size;

  /// Hero icon.
  const AuthUiHeroIcon(this.icon, {super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: ui.primaryGradient,
          borderRadius: BorderRadius.circular(size * 0.3),
          boxShadow: [
            BoxShadow(
              color: ui.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: ui.onPrimary, size: size * 0.5),
      ),
    );
  }
}

/// Screen headline with an optional subtitle.
class AuthUiHeadline extends StatelessWidget {
  /// Title.
  final String title;

  /// Subtitle.
  final String? subtitle;

  /// Headline.
  const AuthUiHeadline({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ui.headlineStyle),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: ui.subtitleStyle),
        ],
      ],
    );
  }
}

/// Small caps label above a text field.
class AuthUiFieldLabel extends StatelessWidget {
  /// Label text.
  final String text;

  /// Field label.
  const AuthUiFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(), style: ui.fieldLabelStyle),
    );
  }
}

/// Rounded text field with a leading icon and a small caps label.
class AuthUiTextField extends StatelessWidget {
  /// Controller.
  final TextEditingController controller;

  /// Label displayed above the field.
  final String? label;

  /// Hint.
  final String? hint;

  /// Leading icon.
  final IconData? icon;

  /// Suffix widget.
  final Widget? suffix;

  /// Obscure text (password).
  final bool obscureText;

  /// On changed.
  final ValueChanged<String>? onChanged;

  /// On submitted.
  final ValueChanged<String>? onSubmitted;

  /// Keyboard action.
  final TextInputAction? textInputAction;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Autofill hints.
  final Iterable<String>? autofillHints;

  /// Autofocus.
  final bool autofocus;

  /// Text field.
  const AuthUiTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.icon,
    this.suffix,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.autofillHints,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthUiTheme.fieldRadius),
          borderSide: BorderSide(color: color, width: width),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) AuthUiFieldLabel(label!),
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          autofocus: autofocus,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ui.subtitleStyle,
            prefixIcon: icon != null ? Icon(icon, color: ui.muted) : null,
            suffixIcon: suffix,
            filled: true,
            fillColor: ui.field,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: border(ui.border),
            enabledBorder: border(ui.border),
            focusedBorder: border(ui.primary, 1.6),
          ),
        ),
      ],
    );
  }
}

/// Password field with a visibility toggle.
class AuthUiPasswordField extends StatefulWidget {
  /// Controller.
  final TextEditingController controller;

  /// Label displayed above the field.
  final String? label;

  /// Hint.
  final String? hint;

  /// On changed.
  final ValueChanged<String>? onChanged;

  /// On submitted.
  final ValueChanged<String>? onSubmitted;

  /// Keyboard action.
  final TextInputAction? textInputAction;

  /// Autofill hints.
  final Iterable<String>? autofillHints;

  /// Tooltip of the toggle when the password is hidden.
  final String? showTooltip;

  /// Tooltip of the toggle when the password is visible.
  final String? hideTooltip;

  /// Password field.
  const AuthUiPasswordField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofillHints,
    this.showTooltip,
    this.hideTooltip,
  });

  @override
  State<AuthUiPasswordField> createState() => _AuthUiPasswordFieldState();
}

class _AuthUiPasswordFieldState extends State<AuthUiPasswordField> {
  var _obscure = true;

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return AuthUiTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint ?? '••••••••••••',
      icon: Icons.lock_outline,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      suffix: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: ui.muted,
        ),
        tooltip: _obscure ? widget.showTooltip : widget.hideTooltip,
        onPressed: () {
          setState(() {
            _obscure = !_obscure;
          });
        },
      ),
    );
  }
}

/// Full width primary (filled) button.
class AuthUiPrimaryButton extends StatelessWidget {
  /// Label.
  final String label;

  /// Trailing icon.
  final IconData? icon;

  /// Leading icon.
  final IconData? leadingIcon;

  /// On pressed (null to disable).
  final VoidCallback? onPressed;

  /// Primary button.
  const AuthUiPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.leadingIcon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthUiTheme.buttonHeight,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthUiTheme.fieldRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: onPressed,
        child: _ButtonContent(
          label: label,
          icon: icon,
          leadingIcon: leadingIcon,
        ),
      ),
    );
  }
}

/// Full width outlined button (secondary actions, third party sign-in).
class AuthUiOutlinedButton extends StatelessWidget {
  /// Label.
  final String label;

  /// Leading icon.
  final IconData? icon;

  /// Custom leading widget (takes precedence over [icon]).
  final Widget? leading;

  /// On pressed (null to disable).
  final VoidCallback? onPressed;

  /// Outlined button.
  const AuthUiOutlinedButton({
    super.key,
    required this.label,
    this.icon,
    this.leading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return SizedBox(
      height: AuthUiTheme.buttonHeight,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthUiTheme.fieldRadius),
          ),
          side: BorderSide(color: ui.border),
          backgroundColor: ui.card,
          foregroundColor: ui.text,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: onPressed,
        child: _ButtonContent(
          label: label,
          leadingIcon: icon,
          leading: leading,
        ),
      ),
    );
  }
}

/// Full width tinted button (for example the red "logout" button).
class AuthUiTintedButton extends StatelessWidget {
  /// Label.
  final String label;

  /// Leading icon.
  final IconData? icon;

  /// Text and icon color.
  final Color color;

  /// Background color.
  final Color softColor;

  /// On pressed (null to disable).
  final VoidCallback? onPressed;

  /// Tinted button.
  const AuthUiTintedButton({
    super.key,
    required this.label,
    required this.color,
    required this.softColor,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthUiTheme.buttonHeight,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthUiTheme.fieldRadius),
            side: BorderSide(color: color.withValues(alpha: 0.25)),
          ),
          backgroundColor: softColor,
          foregroundColor: color,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: onPressed,
        child: _ButtonContent(label: label, leadingIcon: icon),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? leadingIcon;
  final Widget? leading;

  const _ButtonContent({
    required this.label,
    this.icon,
    this.leadingIcon,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 10),
        ] else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 20),
          const SizedBox(width: 10),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 20)],
      ],
    );
  }
}

/// Inline link button (for example "Forgot password?").
class AuthUiLinkButton extends StatelessWidget {
  /// Label.
  final String label;

  /// On pressed.
  final VoidCallback? onPressed;

  /// Link button.
  const AuthUiLinkButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: ui.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

/// Divider with a small caps text in the middle ("or continue with").
class AuthUiOrDivider extends StatelessWidget {
  /// Text.
  final String text;

  /// Divider.
  const AuthUiOrDivider(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: ui.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text.toUpperCase(),
            style: ui.sectionTitleStyle.copyWith(fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: ui.border)),
      ],
    );
  }
}

/// Rounded card grouping rows separated by thin dividers.
class AuthUiCard extends StatelessWidget {
  /// Rows.
  final List<Widget> children;

  /// Add dividers between rows.
  final bool dividers;

  /// Card.
  const AuthUiCard({super.key, required this.children, this.dividers = true});

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    var rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0 && dividers) {
        rows.add(Divider(height: 1, thickness: 1, color: ui.border));
      }
      rows.add(children[i]);
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ui.card,
        borderRadius: BorderRadius.circular(AuthUiTheme.radius),
        border: Border.all(color: ui.border),
        boxShadow: ui.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}

/// Small caps section title with an optional trailing widget.
class AuthUiSectionHeader extends StatelessWidget {
  /// Title.
  final String title;

  /// Trailing widget (for example a link).
  final Widget? trailing;

  /// Section header.
  const AuthUiSectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title.toUpperCase(), style: ui.sectionTitleStyle),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Tinted rounded square with an icon.
class AuthUiIconBox extends StatelessWidget {
  /// Icon.
  final IconData icon;

  /// Icon color.
  final Color color;

  /// Background color.
  final Color softColor;

  /// Size.
  final double size;

  /// Icon box.
  const AuthUiIconBox({
    super.key,
    required this.icon,
    required this.color,
    required this.softColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}

/// Pill badge.
class AuthUiBadge extends StatelessWidget {
  /// Text.
  final String text;

  /// Text color.
  final Color color;

  /// Background color.
  final Color softColor;

  /// Optional icon.
  final IconData? icon;

  /// Badge.
  const AuthUiBadge(
    this.text, {
    super.key,
    required this.color,
    required this.softColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Detail row: icon box, label above value, optional trailing widget.
class AuthUiDetailRow extends StatelessWidget {
  /// Icon.
  final IconData icon;

  /// Icon color.
  final Color color;

  /// Icon background color.
  final Color softColor;

  /// Label (small, muted).
  final String label;

  /// Value (bold).
  final String value;

  /// Use a monospace font for the value.
  final bool monospace;

  /// Trailing widget.
  final Widget? trailing;

  /// On tap.
  final VoidCallback? onTap;

  /// Detail row.
  const AuthUiDetailRow({
    super.key,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.label,
    required this.value,
    this.monospace = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    var valueStyle = monospace
        ? ui.rowValueStyle.copyWith(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          )
        : ui.rowValueStyle;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AuthUiIconBox(icon: icon, color: color, softColor: softColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: ui.rowLabelStyle),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: valueStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Navigation row: icon box, bold title, subtitle and a chevron.
class AuthUiNavRow extends StatelessWidget {
  /// Icon.
  final IconData icon;

  /// Title.
  final String title;

  /// Subtitle.
  final String? subtitle;

  /// On tap.
  final VoidCallback? onTap;

  /// Navigation row.
  const AuthUiNavRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            AuthUiIconBox(
              icon: icon,
              color: ui.neutral,
              softColor: ui.neutralSoft,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ui.rowValueStyle.copyWith(fontSize: 17),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: ui.rowLabelStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: ui.muted),
          ],
        ),
      ),
    );
  }
}

/// Tinted message card (errors, confirmations).
class AuthUiMessageCard extends StatelessWidget {
  /// Text.
  final String text;

  /// Icon.
  final IconData icon;

  /// Icon and border color.
  final Color color;

  /// Background color.
  final Color softColor;

  /// Message card.
  const AuthUiMessageCard({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: ui.rowLabelStyle.copyWith(color: ui.text)),
          ),
        ],
      ),
    );
  }
}

/// Centered footer prompt with a link ("Don't have an account? Sign up").
class AuthUiFooterPrompt extends StatelessWidget {
  /// Text before the link.
  final String text;

  /// Link label.
  final String linkLabel;

  /// Link action.
  final VoidCallback? onTap;

  /// Footer prompt.
  const AuthUiFooterPrompt({
    super.key,
    required this.text,
    required this.linkLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var ui = AuthUiTheme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(text, style: ui.subtitleStyle),
        AuthUiLinkButton(label: linkLabel, onPressed: onTap),
      ],
    );
  }
}
