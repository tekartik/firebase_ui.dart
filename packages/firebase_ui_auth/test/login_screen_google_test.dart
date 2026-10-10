import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_firebase_auth_rest/auth_rest.dart';
// ignore: implementation_imports
import 'package:tekartik_firebase_auth_rest/src/auth_rest_provider.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// The Google provider of a desktop app, without Google: the consent url
/// goes to [userPrompt], the browser comes back when [browser] completes and
/// the user is then signed in by the (mock) built-in provider.
class _FakeGoogleProvider extends AuthProviderRestBase
    implements GoogleRestAuthProvider {
  late PromptUserForConsentRest _userPrompt;
  var browser = Completer<void>();

  @override
  set userPrompt(PromptUserForConsentRest userPrompt) {
    _userPrompt = userPrompt;
  }

  @override
  String get providerId => 'google.com';

  @override
  void addScope(String scope) {}

  @override
  Future<AuthSignInResult> signIn() async {
    _userPrompt('https://accounts.google.com/o/oauth2/auth?test');
    await browser.future;
    return _Result(await authRest.signInAnonymously());
  }

  @override
  Future<void> signOut() => authRest.signOut();
}

class _Result implements AuthSignInResult {
  @override
  final UserCredential credential;

  _Result(this.credential);

  @override
  bool get hasInfo => true;
}

Widget _testApp(Widget home) => MaterialApp(
  localizationsDelegates: const [
    FirebaseUiAuthServiceBasicLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: FirebaseUiAuthServiceBasicLocalizations.supportedLocales,
  home: home,
);

/// Real delays for the auth streams, fake clock pumps for the screens (the
/// busy indicator never settles).
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pump();
}

void main() {
  late FirebaseAuth auth;
  late _FakeGoogleProvider google;
  late List<String> launched;
  const urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');

  setUp(() async {
    google = _FakeGoogleProvider();
    var authService = FirebaseAuthServiceRest(
      persistence: FirebaseRestAuthPersistenceMemory(),
      providers: () => [MockBuiltInAuthProviderRest(), google],
    );
    var app = firebaseRest.initializeApp(
      name: 'login_google',
      options: FirebaseAppOptions(projectId: 'login_google'),
    );
    auth = authService.auth(app);
    launched = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, (call) async {
          launched.add((call.arguments as Map)['url'] as String);
          return true;
        });
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(urlLauncherChannel, null);
    await auth.app.delete();
  });

  /// A home pushing the login screen, [result] gets what it pops with.
  Future<List<User?>> openLogin(WidgetTester tester) async {
    var result = <User?>[];
    await tester.pumpWidget(
      _testApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result.add(
                  await Navigator.of(context).push<User?>(
                    MaterialPageRoute(
                      builder: (_) => authLoginScreen(firebaseAuth: auth),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _settle(tester);
    return result;
  }

  Future<void> tapGoogle(WidgetTester tester) async {
    var button = find.text('Google');
    await tester.ensureVisible(button);
    await tester.pump();
    await tester.tap(button);
    await _settle(tester);
  }

  testWidgets('google: browser opened, signed in, back home', (tester) async {
    var result = await openLogin(tester);
    await tapGoogle(tester);

    // The browser opened on the consent url, the dialog waits for it.
    expect(launched, ['https://accounts.google.com/o/oauth2/auth?test']);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    google.browser.complete();
    await _settle(tester);

    // Dialog and login screen gone, the screen popped with the user.
    expect(find.text('Sign in with Google'), findsNothing);
    expect(find.text('Google'), findsNothing);
    expect(find.text('open'), findsOneWidget);
    expect(result.single?.uid, auth.currentUser!.uid);
  });

  testWidgets('google: cancel', (tester) async {
    var result = await openLogin(tester);
    await tapGoogle(tester);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await _settle(tester);

    // Back on the login screen, not busy: Google can be tried again.
    expect(find.text('Sign in with Google'), findsNothing);
    expect(result, isEmpty);
    google.browser = Completer<void>();
    await tapGoogle(tester);
    expect(find.text('Cancel'), findsOneWidget);
    expect(launched, hasLength(2));
    google.browser.complete();
    await _settle(tester);
    expect(find.text('open'), findsOneWidget);
    expect(result.single, isNotNull);
  });
}
