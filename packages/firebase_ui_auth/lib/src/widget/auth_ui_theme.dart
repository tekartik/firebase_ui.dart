import 'package:material_ui/material_ui.dart';

/// How the auth screens draw their page and their surfaces.
enum AuthUiStyle {
  /// Follow the app theme (default): the flat page color of the theme
  /// (`scaffoldBackgroundColor`), the color and border of its cards
  /// (`cardTheme`), the fill and border of its fields
  /// (`inputDecorationTheme`), no card shadow when its cards have no
  /// elevation. What the theme does not set keeps the [classic] value.
  app,

  /// The original look: a page gradient tinted by the primary color, white
  /// cards with a soft shadow in light mode, whatever the app theme sets for
  /// its cards and fields.
  classic,
}

/// Selects the [AuthUiStyle] of the auth screens in a [ThemeData]:
/// `ThemeData(extensions: [AuthUiStyleExtension(AuthUiStyle.classic)])`, or
/// `theme.withAuthUiStyle(AuthUiStyle.classic)` on an existing theme.
class AuthUiStyleExtension extends ThemeExtension<AuthUiStyleExtension> {
  /// The style.
  final AuthUiStyle style;

  /// Style extension.
  const AuthUiStyleExtension(this.style);

  @override
  AuthUiStyleExtension copyWith({AuthUiStyle? style}) =>
      AuthUiStyleExtension(style ?? this.style);

  @override
  AuthUiStyleExtension lerp(covariant AuthUiStyleExtension? other, double t) =>
      (other == null || t < 0.5) ? this : other;
}

/// [AuthUiStyle] helpers on [ThemeData].
extension AuthUiThemeDataExtension on ThemeData {
  /// This theme with the auth screens in [style], its other extensions kept.
  ThemeData withAuthUiStyle(AuthUiStyle style) => copyWith(
    extensions: [
      ...extensions.values.where((ext) => ext is! AuthUiStyleExtension),
      AuthUiStyleExtension(style),
    ],
  );
}

/// Design tokens used by the auth screens, derived from the app [ThemeData].
///
/// The screens follow the app color scheme and, in the default
/// [AuthUiStyle.app], its page, card and field colors: a festenao theme
/// (`festenao_theme`) shows them on its own paper. [AuthUiStyle.classic]
/// (`theme.withAuthUiStyle(AuthUiStyle.classic)`) brings back the original
/// tinted gradient page; with a violet seed color on the theme
/// (`ThemeData(colorSchemeSeed: Color(0xFF5B4FE9))`) it is the reference look.
/// Light and dark themes are supported.
class AuthUiTheme {
  /// The app theme.
  final ThemeData theme;

  /// The style: [AuthUiStyleExtension] of [theme] if any, else
  /// [AuthUiStyle.app].
  final AuthUiStyle style;

  /// Constructor, [style] overriding the one of [theme].
  AuthUiTheme(this.theme, {AuthUiStyle? style})
    : style =
          style ??
          theme.extension<AuthUiStyleExtension>()?.style ??
          AuthUiStyle.app;

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

  /// Whether in [AuthUiStyle.classic].
  bool get isClassic => style == AuthUiStyle.classic;

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

  /// The flat page color of [AuthUiStyle.app]: the theme
  /// `scaffoldBackgroundColor`.
  Color get pageColor => theme.scaffoldBackgroundColor;

  /// Page background: [pageColor] in [AuthUiStyle.app], [pageGradient] in
  /// [AuthUiStyle.classic].
  Decoration get pageDecoration => isClassic
      ? BoxDecoration(gradient: pageGradient)
      : BoxDecoration(color: pageColor);

  /// The classic card color.
  Color get _classicCard => isDark ? scheme.surfaceContainerHigh : Colors.white;

  /// Card background: the theme `cardTheme.color` in [AuthUiStyle.app].
  Color get card =>
      isClassic ? _classicCard : theme.cardTheme.color ?? _classicCard;

  /// The classic field color.
  Color get _classicField =>
      isDark ? scheme.surfaceContainerHighest : Colors.white;

  /// Text field background: the theme `inputDecorationTheme.fillColor` (when
  /// `filled`) in [AuthUiStyle.app].
  Color get field {
    if (!isClassic) {
      var inputTheme = theme.inputDecorationTheme;
      var fillColor = inputTheme.fillColor;
      if (inputTheme.filled && fillColor != null) {
        return fillColor;
      }
    }
    return _classicField;
  }

  /// The classic border color.
  Color get _classicBorder => scheme.outlineVariant.withValues(alpha: 0.6);

  /// Card and divider border color: the side of the theme `cardTheme.shape`
  /// in [AuthUiStyle.app].
  Color get border {
    if (!isClassic) {
      var shape = theme.cardTheme.shape;
      if (shape is OutlinedBorder && shape.side.style != BorderStyle.none) {
        return shape.side.color;
      }
    }
    return _classicBorder;
  }

  /// Text field border color: the side of the theme
  /// `inputDecorationTheme.enabledBorder` in [AuthUiStyle.app], else
  /// [border].
  Color get fieldBorder {
    if (!isClassic) {
      var side = theme.inputDecorationTheme.enabledBorder?.borderSide;
      if (side != null && side.style != BorderStyle.none) {
        return side.color;
      }
    }
    return border;
  }

  /// Card shadow: none in dark mode, nor in [AuthUiStyle.app] when the theme
  /// cards have no elevation.
  List<BoxShadow> get cardShadow =>
      isDark || (!isClassic && theme.cardTheme.elevation == 0)
      ? const []
      : [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ];

  /// Page background gradient of [AuthUiStyle.classic].
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

  /// Full width button label style.
  ///
  /// Derived from the theme so that the app font family applies (a button
  /// text style replaces the theme one, it is not merged with it).
  TextStyle get buttonTextStyle =>
      (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );

  /// Inline link button label style.
  TextStyle get linkTextStyle =>
      (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
      );

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
