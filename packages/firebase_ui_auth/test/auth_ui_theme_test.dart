import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_firebase_ui_auth/src/widget/auth_ui_widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

const _paper = Color(0xFFF4F5F7);
const _card = Color(0xFFFFFFFE);
const _line = Color(0xFFDDDFE3);
const _fill = Color(0xFFFAFAFB);
const _lineStrong = Color(0xFFB8BCC4);

/// A theme setting its page, cards and fields, as festenao_theme does.
ThemeData _paperTheme({Brightness brightness = Brightness.light}) => ThemeData(
  brightness: brightness,
  scaffoldBackgroundColor: _paper,
  cardTheme: CardThemeData(
    color: _card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: _line),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _fill,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _lineStrong),
    ),
  ),
);

/// A test extension, to check that the others are kept.
class _OtherExtension extends ThemeExtension<_OtherExtension> {
  const _OtherExtension();

  @override
  _OtherExtension copyWith() => this;

  @override
  _OtherExtension lerp(covariant _OtherExtension? other, double t) => this;
}

Color? _decorationColor(Decoration decoration) =>
    (decoration as BoxDecoration).color;

void main() {
  group('AuthUiTheme', () {
    test('app style by default, the theme page, cards and fields', () {
      var ui = AuthUiTheme(_paperTheme());
      expect(ui.style, AuthUiStyle.app);
      expect(ui.isClassic, isFalse);
      expect(_decorationColor(ui.pageDecoration), _paper);
      expect((ui.pageDecoration as BoxDecoration).gradient, isNull);
      expect(ui.card, _card);
      expect(ui.border, _line);
      expect(ui.field, _fill);
      expect(ui.fieldBorder, _lineStrong);
      expect(ui.cardShadow, isEmpty);
    });

    test('app style on a theme setting nothing: the classic surfaces', () {
      var theme = ThemeData(colorSchemeSeed: const Color(0xFF5B4FE9));
      var ui = AuthUiTheme(theme);
      var classic = AuthUiTheme(theme, style: AuthUiStyle.classic);
      expect(
        _decorationColor(ui.pageDecoration),
        theme.scaffoldBackgroundColor,
      );
      expect(ui.card, Colors.white);
      expect(ui.card, classic.card);
      expect(ui.field, classic.field);
      expect(ui.border, classic.border);
      expect(ui.fieldBorder, classic.border);
      expect(ui.cardShadow, isNotEmpty);
    });

    test('classic style ignores the theme surfaces', () {
      var theme = _paperTheme().withAuthUiStyle(AuthUiStyle.classic);
      var ui = AuthUiTheme(theme);
      expect(ui.style, AuthUiStyle.classic);
      var decoration = ui.pageDecoration as BoxDecoration;
      expect(decoration.color, isNull);
      expect(decoration.gradient, ui.pageGradient);
      expect(ui.card, Colors.white);
      expect(ui.field, Colors.white);
      expect(ui.border, isNot(_line));
      expect(ui.fieldBorder, ui.border);
      expect(ui.cardShadow, isNotEmpty);
    });

    test('dark: no shadow in either style', () {
      var theme = _paperTheme(brightness: Brightness.dark);
      expect(AuthUiTheme(theme).cardShadow, isEmpty);
      expect(
        AuthUiTheme(theme, style: AuthUiStyle.classic).cardShadow,
        isEmpty,
      );
    });

    test('withAuthUiStyle keeps the other extensions', () {
      var theme = ThemeData(extensions: const [_OtherExtension()])
          .withAuthUiStyle(AuthUiStyle.classic);
      expect(theme.extension<_OtherExtension>(), isNotNull);
      expect(
        theme.extension<AuthUiStyleExtension>()?.style,
        AuthUiStyle.classic,
      );
      theme = theme.withAuthUiStyle(AuthUiStyle.app);
      expect(theme.extension<_OtherExtension>(), isNotNull);
      expect(theme.extension<AuthUiStyleExtension>()?.style, AuthUiStyle.app);
      // The style given to the constructor wins.
      expect(
        AuthUiTheme(theme, style: AuthUiStyle.classic).style,
        AuthUiStyle.classic,
      );
    });

    test('lerp switches at half way', () {
      const app = AuthUiStyleExtension(AuthUiStyle.app);
      const classic = AuthUiStyleExtension(AuthUiStyle.classic);
      expect(app.lerp(classic, 0.4).style, AuthUiStyle.app);
      expect(app.lerp(classic, 0.6).style, AuthUiStyle.classic);
      expect(app.lerp(null, 1).style, AuthUiStyle.app);
      expect(app.copyWith(style: AuthUiStyle.classic).style, classic.style);
    });
  });

  group('AuthUiScaffold page', () {
    Future<BoxDecoration> pageDecoration(
      WidgetTester tester,
      ThemeData theme,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const AuthUiScaffold(title: 'Page', children: [Text('Body')]),
        ),
      );
      var box = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byType(Scaffold),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return box.decoration as BoxDecoration;
    }

    testWidgets('app: the theme page color', (tester) async {
      var decoration = await pageDecoration(tester, _paperTheme());
      expect(decoration.color, _paper);
      expect(decoration.gradient, isNull);
    });

    testWidgets('classic: the gradient', (tester) async {
      var decoration = await pageDecoration(
        tester,
        _paperTheme().withAuthUiStyle(AuthUiStyle.classic),
      );
      expect(decoration.color, isNull);
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });
}
