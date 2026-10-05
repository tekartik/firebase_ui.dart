import 'package:material_ui/material_ui.dart';

/// Hosts a flutterfire ui screen, still built on
/// `package:flutter/material.dart` (`SignInScreen`, `RegisterScreen`,
/// `ProfileScreen`...), in a `material_ui` app: the bridge derives the
/// flutter `Theme` and `MaterialLocalizations` those widgets look up from
/// the app theme and its localizations. Goes away when firebase_ui_auth
/// moves to material_ui (projects.dart `doc/material_ui_migration_plan.md`
/// §4.4).
Widget legacyMaterialScreen(Widget screen) =>
    // A migration utility, deprecated on purpose from its first release.
    // ignore: deprecated_member_use
    MaterialUiCompatibilityBridge(child: screen);
