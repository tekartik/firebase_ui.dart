/// Renders the auth screens (welcome, sign in, sign up, lost password,
/// profile, email verification) as pngs.
///
/// It goes through the flutter test pipeline rather than a running window:
/// the screens are the real ones on an in-memory sdb auth backend, seeded per
/// scenario, nothing needs a display.
///
/// ```sh
/// flutter test tool/screenshot_test.dart
/// flutter test tool/screenshot_test.dart --dart-define=UI_AUTH_SCREENSHOT_DIR=../../.local/2026-10-08
/// ```
///
/// The pngs land in `.local/screenshots` (git ignored) unless
/// `UI_AUTH_SCREENSHOT_DIR` says otherwise: `<variant>_NN_name.png`, the
/// phone at 400x860, the desktop at 1280x800, both at a pixel ratio of 2.
/// The errors a screen reports (an overflow for instance) are listed at the
/// end rather than stopping the run.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_firebase_auth_sdb/auth_sdb.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Where the pngs land.
const screenshotDirectory = String.fromEnvironment(
  'UI_AUTH_SCREENSHOT_DIR',
  defaultValue: '.local/screenshots',
);

/// A phone, portrait.
const phoneSize = Size(400, 860);

/// A laptop.
const desktopSize = Size(1280, 800);

/// The pixel ratio of the pngs.
const pixelRatio = 2.0;

/// The reference seed color of the auth screens (see `AuthUiTheme`).
const seedColor = Color(0xFF5B4FE9);

final _rootKey = GlobalKey();

/// What the screens reported, by screenshot.
final _errors = <String, String>{};

/// Where the flutter sdk keeps the fonts a running app is given.
String get _flutterFontsPath {
  var root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    // dart is `<flutter>/bin/cache/dart-sdk/bin/dart`.
    var directory = File(Platform.resolvedExecutable)
        .parent
        .parent
        .parent
        .parent
        .parent;
    root = directory.path;
  }
  return '$root/bin/cache/artifacts/material_fonts';
}

Future<ByteData> _readFont(File file) =>
    file.readAsBytes().then((bytes) => ByteData.view(bytes.buffer));

Future<void> _loadFamily(String family, List<File> files) async {
  var existing = files.where((file) => file.existsSync()).toList();
  if (existing.isEmpty) {
    // ignore: avoid_print
    print('no font for $family, its text will draw as boxes');
    return;
  }
  var loader = FontLoader(family);
  for (var file in existing) {
    loader.addFont(_readFont(file));
  }
  await loader.load();
}

/// Loads the fonts a running app has.
///
/// The test harness draws with a font that shows every glyph as a box: Roboto
/// and the material icons come from the flutter sdk, the user id row asks for
/// `monospace`, given DejaVu Sans Mono when the system has it.
Future<void> _loadFonts() async {
  await _loadFamily('Roboto', [
    for (var name in ['Thin', 'Light', 'Regular', 'Medium', 'Bold', 'Black'])
      File('$_flutterFontsPath/Roboto-$name.ttf'),
  ]);
  await _loadFamily('MaterialIcons', [
    File('$_flutterFontsPath/MaterialIcons-Regular.otf'),
  ]);
  await _loadFamily('monospace', [
    File('/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf'),
    File('/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf'),
  ]);
}

/// Lets the really asynchronous backend (the sdb database) and the 300ms
/// delays after the auth actions settle, pumping between real delays.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 15));
  }
}

/// Sizes the window, [MediaQuery] included.
Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = pixelRatio;
  tester.view.physicalSize = size * pixelRatio;
  await tester.binding.setSurfaceSize(size);
}

/// One way of showing the screens: size, theme and language.
class _Variant {
  final String name;
  final Size size;
  final Brightness brightness;
  final Locale locale;

  /// Shot names to take, all when null.
  final Set<String>? only;

  const _Variant(
    this.name, {
    this.size = phoneSize,
    this.brightness = Brightness.light,
    this.locale = const Locale('en'),
    this.only,
  });
}

const _variants = [
  _Variant('phone_light'),
  _Variant('phone_dark', brightness: Brightness.dark),
  _Variant(
    'desktop_light',
    size: desktopSize,
    only: {'welcome', 'sign_in_error', 'signed_in', 'profile_verified'},
  ),
  _Variant(
    'desktop_dark',
    size: desktopSize,
    brightness: Brightness.dark,
    only: {'welcome', 'profile_verified'},
  ),
  _Variant(
    'phone_fr',
    locale: Locale('fr'),
    only: {'welcome', 'sign_in_error', 'sign_up_mismatch', 'profile'},
  ),
];

/// Signed out state, a user that can sign in.
const _email = 'camille.martin@example.com';
const _password = 'password1';

/// The user of the verified profile.
const _verifiedEmail = 'alex.dupont@example.com';
const _verifiedName = 'Alex Dupont';

/// A scenario: seeds [auth], shows a screen and brings it to the state shot.
typedef _Scenario = Future<void> Function(
  WidgetTester tester,
  FirebaseAuthSdb auth,
  Future<void> Function(Widget screen) show,
);

Future<void> _enterField(WidgetTester tester, int index, String text) async {
  await tester.enterText(find.byType(TextField).at(index), text);
  await tester.pump();
}

/// Scrolls to and taps the last widget showing [text] (a title and a button
/// can share a label).
Future<void> _tapText(WidgetTester tester, String text) async {
  var finder = find.text(text).last;
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _settle(tester);
}

/// Creates the regular (unverified, unnamed) user, signed out.
Future<void> _seedUser(FirebaseAuthSdb auth) async {
  await auth.createUser(
    FirebaseAuthCreateUserRequest(email: _email, password: _password),
  );
}

/// Creates the regular user and signs them in.
Future<void> _seedSignedIn(FirebaseAuthSdb auth) async {
  await _seedUser(auth);
  await auth.signInWithEmailAndPassword(email: _email, password: _password);
}

/// Creates a named, verified user and signs them in.
Future<void> _seedSignedInVerified(FirebaseAuthSdb auth) async {
  await auth.createUser(
    FirebaseAuthCreateUserRequest(
      email: _verifiedEmail,
      password: _password,
      displayName: _verifiedName,
      emailVerified: true,
    ),
  );
  await auth.signInWithEmailAndPassword(
    email: _verifiedEmail,
    password: _password,
  );
}

const _service = firebaseUiAuthServiceBasic;
const _serviceRestricted = FirebaseUiAuthServiceBasic(
  options: FirebaseUiAuthOptions(
    registerEnabled: false,
    lostPasswordEnabled: false,
  ),
);

/// The shots, by name, in order.
final _scenarios = <String, _Scenario>{
  'welcome': (tester, auth, show) async {
    await show(_service.authScreen(firebaseAuth: auth));
  },
  'welcome_no_sign_up': (tester, auth, show) async {
    await show(_serviceRestricted.authScreen(firebaseAuth: auth));
  },
  'sign_in': (tester, auth, show) async {
    await show(_service.loginScreen(firebaseAuth: auth));
  },
  'sign_in_filled': (tester, auth, show) async {
    await _seedUser(auth);
    await show(_service.loginScreen(firebaseAuth: auth));
    await _enterField(tester, 0, _email);
    await _enterField(tester, 1, _password);
  },
  'sign_in_error': (tester, auth, show) async {
    await _seedUser(auth);
    await show(_service.loginScreen(firebaseAuth: auth));
    await _enterField(tester, 0, _email);
    await _enterField(tester, 1, 'wrong password');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _settle(tester);
  },
  'sign_in_no_sign_up': (tester, auth, show) async {
    await show(_serviceRestricted.loginScreen(firebaseAuth: auth));
  },
  'sign_up': (tester, auth, show) async {
    await show(_service.registerScreen(firebaseAuth: auth));
  },
  'sign_up_mismatch': (tester, auth, show) async {
    await show(_service.registerScreen(firebaseAuth: auth));
    await _enterField(tester, 0, 'new.user@example.com');
    await _enterField(tester, 1, _password);
    await _enterField(tester, 2, 'password2');
  },
  'lost_password': (tester, auth, show) async {
    await show(_service.lostPasswordScreen(firebaseAuth: auth, email: _email));
  },
  'lost_password_sent': (tester, auth, show) async {
    await _seedUser(auth);
    await show(_service.lostPasswordScreen(firebaseAuth: auth, email: _email));
    await _tapText(tester, _lostPasswordButton(tester));
  },
  'lost_password_unknown': (tester, auth, show) async {
    await show(
      _service.lostPasswordScreen(
        firebaseAuth: auth,
        email: 'nobody@example.com',
      ),
    );
    await _tapText(tester, _lostPasswordButton(tester));
  },
  'signed_in': (tester, auth, show) async {
    await _seedSignedIn(auth);
    await show(_service.authScreen(firebaseAuth: auth));
  },
  'profile': (tester, auth, show) async {
    await _seedSignedIn(auth);
    await show(_service.profileScreen(firebaseAuth: auth));
  },
  'profile_verified': (tester, auth, show) async {
    await _seedSignedInVerified(auth);
    await show(_service.profileScreen(firebaseAuth: auth));
  },
  'signed_in_verified': (tester, auth, show) async {
    await _seedSignedInVerified(auth);
    await show(_service.authScreen(firebaseAuth: auth));
  },
  'email_verification': (tester, auth, show) async {
    await _seedSignedIn(auth);
    await show(_service.emailVerificationScreen(firebaseAuth: auth));
  },
  'email_verification_not_yet': (tester, auth, show) async {
    await _seedSignedIn(auth);
    await show(_service.emailVerificationScreen(firebaseAuth: auth));
    await _tapText(tester, _intl(tester).emailVerificationCheckButtonLabel);
  },
};

FirebaseUiAuthServiceBasicLocalizations _intl(WidgetTester tester) =>
    FirebaseUiAuthServiceBasicLocalizations.of(
      tester.element(find.byType(Scaffold).last),
    )!;

String _lostPasswordButton(WidgetTester tester) =>
    _intl(tester).lostPasswordButtonLabel;

void main() {
  testWidgets('screenshots', (tester) async {
    await tester.runAsync(() async {
      await _loadFonts();
      for (var variant in _variants) {
        await _setSize(tester, variant.size);
        var index = 0;
        for (var entry in _scenarios.entries) {
          var name = entry.key;
          if (variant.only != null && !variant.only!.contains(name)) {
            continue;
          }
          var fileName =
              '${variant.name}_${(++index).toString().padLeft(2, '0')}_$name';
          var auth = newFirebaseAuthSdbMemory() as FirebaseAuthSdb;
          Future<void> show(Widget screen) async {
            await tester.pumpWidget(
              RepaintBoundary(
                key: _rootKey,
                child: MaterialApp(
                  key: UniqueKey(),
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    colorSchemeSeed: seedColor,
                    brightness: variant.brightness,
                  ),
                  locale: variant.locale,
                  localizationsDelegates: const [
                    FirebaseUiAuthServiceBasicLocalizations.delegate,
                    ...GlobalMaterialLocalizations.delegates,
                  ],
                  supportedLocales:
                      FirebaseUiAuthServiceBasicLocalizations.supportedLocales,
                  // A screen pushed over a home, as an app shows it (back
                  // arrow). Without onGenerateRoute (nor home nor routes)
                  // there is no Navigator at all.
                  onGenerateRoute: (_) =>
                      MaterialPageRoute<void>(builder: (_) => screen),
                  onGenerateInitialRoutes: (_) => [
                    MaterialPageRoute<void>(builder: (_) => const Scaffold()),
                    MaterialPageRoute<void>(builder: (_) => screen),
                  ],
                ),
              ),
            );
            await _settle(tester);
          }

          await entry.value(tester, auth, show);
          await _shot(tester, fileName);
          await tester.pumpWidget(const SizedBox());
          await auth.app.delete();
        }
      }
    });
    if (_errors.isNotEmpty) {
      // ignore: avoid_print
      print('errors:');
      for (var entry in _errors.entries) {
        // ignore: avoid_print
        print('${entry.key}: ${entry.value}');
      }
    }
  });
}

/// Writes what is on screen as `<fileName>.png`.
Future<void> _shot(WidgetTester tester, String fileName) async {
  await _settle(tester);
  // Hide the text cursor.
  FocusManager.instance.primaryFocus?.unfocus();
  await _settle(tester);
  var exception = tester.takeException();
  if (exception != null) {
    _errors[fileName] = '$exception';
  }
  var boundary =
      tester.renderObject(find.byKey(_rootKey)) as RenderRepaintBoundary;
  var image = await boundary.toImage(pixelRatio: pixelRatio);
  var bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  var file = File('$screenshotDirectory/$fileName.png');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  // ignore: avoid_print
  print('wrote ${file.path}');
}
