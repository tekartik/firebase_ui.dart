import 'package:material_ui/material_ui.dart';

/// A theme of the example: a seed color and a scheme variant.
class ExampleTheme {
  /// Name.
  final String name;

  /// Seed color.
  final Color seedColor;

  /// How the scheme is derived from the seed color.
  final DynamicSchemeVariant variant;

  /// Theme.
  const ExampleTheme(
    this.name,
    this.seedColor, {
    this.variant = DynamicSchemeVariant.tonalSpot,
  });

  /// Color scheme for [brightness].
  ColorScheme colorScheme(Brightness brightness) => ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    dynamicSchemeVariant: variant,
  );

  /// Theme data for [brightness].
  ThemeData themeData(Brightness brightness) =>
      ThemeData(colorScheme: colorScheme(brightness));
}

/// The themes, the first one being the reference look of the auth screens.
const exampleThemes = [
  ExampleTheme('Violet', Color(0xFF5B4FE9)),
  ExampleTheme('Teal', Color(0xFF00897B)),
  ExampleTheme(
    'Coral',
    Color(0xFFE5533D),
    variant: DynamicSchemeVariant.vibrant,
  ),
  ExampleTheme(
    'Forest',
    Color(0xFF2E7D32),
    variant: DynamicSchemeVariant.fidelity,
  ),
  ExampleTheme(
    'Ocean',
    Color(0xFF1565C0),
    variant: DynamicSchemeVariant.expressive,
  ),
  ExampleTheme(
    'Graphite',
    Color(0xFF607D8B),
    variant: DynamicSchemeVariant.monochrome,
  ),
];

/// A theme in light or dark.
class ExampleThemeChoice {
  /// Theme.
  final ExampleTheme theme;

  /// Light or dark.
  final Brightness brightness;

  /// Theme choice.
  const ExampleThemeChoice(this.theme, this.brightness);

  /// Whether dark.
  bool get isDark => brightness == Brightness.dark;

  /// Displayed name (`Violet light`).
  String get label => '${theme.name} ${isDark ? 'dark' : 'light'}';

  /// Color scheme.
  ColorScheme get colorScheme => theme.colorScheme(brightness);

  /// Theme data.
  ThemeData get themeData => theme.themeData(brightness);
}

/// Every theme, light then dark: the order of the one tap cycle.
final exampleThemeChoices = [
  for (var theme in exampleThemes)
    for (var brightness in Brightness.values.reversed)
      ExampleThemeChoice(theme, brightness),
];

/// Current theme, as an index in [exampleThemeChoices].
class ExampleThemeController extends ValueNotifier<int> {
  /// Starts at [index].
  ExampleThemeController({int index = 0}) : super(index);

  /// Starts with the first theme in the platform brightness.
  factory ExampleThemeController.platform() {
    var brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return ExampleThemeController(
      index: exampleThemeChoices.indexWhere(
        (choice) => choice.brightness == brightness,
      ),
    );
  }

  /// Current choice.
  ExampleThemeChoice get choice => exampleThemeChoices[value];

  /// The choice [next] selects.
  ExampleThemeChoice get nextChoice =>
      exampleThemeChoices[(value + 1) % exampleThemeChoices.length];

  /// Next theme (light, then dark, then the next theme in light).
  void next() {
    value = (value + 1) % exampleThemeChoices.length;
  }

  /// Select [theme], keeping the brightness.
  void selectTheme(ExampleTheme theme) => _select(theme, choice.brightness);

  /// Select [brightness], keeping the theme.
  void selectBrightness(Brightness brightness) =>
      _select(choice.theme, brightness);

  void _select(ExampleTheme theme, Brightness brightness) {
    value = exampleThemeChoices.indexWhere(
      (choice) => choice.theme == theme && choice.brightness == brightness,
    );
  }
}

/// Makes the [ExampleThemeController] available to the screens.
class ExampleThemeScope extends InheritedNotifier<ExampleThemeController> {
  /// Theme scope.
  const ExampleThemeScope({
    super.key,
    required ExampleThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The controller (the caller rebuilds when the theme changes).
  static ExampleThemeController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ExampleThemeScope>()!
      .notifier!;
}

/// App bar actions: next theme in one tap, and a menu of all the themes.
class ExampleThemeActions extends StatelessWidget {
  /// Theme actions.
  const ExampleThemeActions({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = ExampleThemeScope.of(context);
    var current = controller.choice;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.palette_outlined),
          tooltip: 'Next theme: ${controller.nextChoice.label}',
          onPressed: controller.next,
        ),
        PopupMenuButton<ExampleThemeChoice>(
          icon: const Icon(Icons.format_paint_outlined),
          tooltip: 'Theme: ${current.label}',
          initialValue: current,
          onSelected: (choice) {
            controller.value = exampleThemeChoices.indexOf(choice);
          },
          itemBuilder: (context) => [
            for (var choice in exampleThemeChoices)
              PopupMenuItem(
                value: choice,
                child: Row(
                  children: [
                    ExampleThemeSwatch(choice: choice),
                    const SizedBox(width: 12),
                    Text(choice.label),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A small disc showing the primary color of [choice] on its surface.
class ExampleThemeSwatch extends StatelessWidget {
  /// The theme shown.
  final ExampleThemeChoice choice;

  /// Size.
  final double size;

  /// Swatch.
  const ExampleThemeSwatch({super.key, required this.choice, this.size = 24});

  @override
  Widget build(BuildContext context) {
    var scheme = choice.colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: EdgeInsets.all(size / 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primary,
        ),
      ),
    );
  }
}
