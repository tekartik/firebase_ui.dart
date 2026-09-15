import 'package:flutter/material.dart';

/// Design tokens used by the auth screens, derived from the app [ThemeData].
///
/// The screens follow the app color scheme: use a violet seed color on your
/// theme (`ThemeData(colorSchemeSeed: Color(0xFF5B4FE9))`) to get the
/// reference look. Light and dark themes are supported.
class AuthUiTheme {
  /// The app theme.
  final ThemeData theme;

  /// Constructor.
  AuthUiTheme(this.theme);

  /// From context.
  factory AuthUiTheme.of(BuildContext context) =>
      AuthUiTheme(Theme.of(context));

  /// Card and hero corner radius.
  static const double radius = 20;

  /// Text field and button corner radius.
  static const double fieldRadius = 16;

  /// Primary button height.
  static const double buttonHeight = 56;

  /// Max content width.
  static const double maxWidth = 520;

  /// Horizontal page padding.
  static const double pagePadding = 20;

  /// Color scheme.
  ColorScheme get scheme => theme.colorScheme;

  /// Dark mode.
  bool get isDark => theme.brightness == Brightness.dark;

  /// Primary (accent) color.
  Color get primary => scheme.primary;

  /// Color on primary.
  Color get onPrimary => scheme.onPrimary;

  /// Soft primary tint (icon boxes, badges).
  Color get primarySoft => primary.withValues(alpha: isDark ? 0.28 : 0.10);

  /// Success color (verified, active).
  Color get success =>
      isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);

  /// Soft success tint.
  Color get successSoft => success.withValues(alpha: isDark ? 0.24 : 0.12);

  /// Warning color (pending).
  Color get warning =>
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

  /// Soft warning tint.
  Color get warningSoft => warning.withValues(alpha: isDark ? 0.24 : 0.12);

  /// Info color (email).
  Color get info => isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);

  /// Soft info tint.
  Color get infoSoft => info.withValues(alpha: isDark ? 0.24 : 0.12);

  /// Danger color (logout, errors).
  Color get danger => scheme.error;

  /// Soft danger tint.
  Color get dangerSoft => danger.withValues(alpha: isDark ? 0.24 : 0.08);

  /// Neutral color (secondary badges).
  Color get neutral => scheme.onSurfaceVariant;

  /// Soft neutral tint.
  Color get neutralSoft => neutral.withValues(alpha: isDark ? 0.24 : 0.10);

  /// Muted text color.
  Color get muted => scheme.onSurfaceVariant;

  /// Main text color.
  Color get text => scheme.onSurface;

  /// Card background.
  Color get card => isDark ? scheme.surfaceContainerHigh : Colors.white;

  /// Text field background.
  Color get field => isDark ? scheme.surfaceContainerHighest : Colors.white;

  /// Card and field border color.
  Color get border => scheme.outlineVariant.withValues(alpha: 0.6);

  /// Card shadow.
  List<BoxShadow> get cardShadow => isDark
      ? const []
      : [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ];

  /// Page background gradient.
  Gradient get pageGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.alphaBlend(
        primary.withValues(alpha: isDark ? 0.12 : 0.07),
        scheme.surface,
      ),
      scheme.surface,
    ],
  );

  /// Primary gradient (hero icon, avatar).
  Gradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color.lerp(primary, Colors.white, 0.22)!],
  );

  /// Section title style (small caps).
  TextStyle get sectionTitleStyle =>
      (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
        color: muted,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      );

  /// App bar title style (small caps).
  TextStyle get appBarTitleStyle => sectionTitleStyle.copyWith(fontSize: 14);

  /// Field label style (small caps).
  TextStyle get fieldLabelStyle =>
      (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
        color: text,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      );

  /// Headline style.
  TextStyle get headlineStyle =>
      (theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 28))
          .copyWith(
            color: text,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          );

  /// Subtitle style.
  TextStyle get subtitleStyle =>
      (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(color: muted);

  /// Detail row label style.
  TextStyle get rowLabelStyle =>
      (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(color: muted);

  /// Detail row value style.
  TextStyle get rowValueStyle =>
      (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
        color: text,
        fontWeight: FontWeight.w700,
      );
}
