import 'package:firebase_core/firebase_core.dart' as native;
import 'package:flutter/foundation.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_auth_rest/auth_rest.dart';
import 'package:tekartik_firebase_firestore_flutter/firestore_flutter.dart';
import 'package:tekartik_firebase_firestore_rest/firestore_rest.dart';
import 'package:tekartik_firebase_flutter/firebase_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';
import 'package:tekartik_firebase_rest/firebase_rest.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

import 'emulator_config.dart';
import 'firebase_options.dart';

/// Everything the screens need: the auth and firestore instances of the
/// current backend and the ui auth service to use.
class ExampleFirebaseContext {
  /// `native`, `rest` or `local`.
  final String backendName;

  /// The app.
  final FirebaseApp app;

  /// Auth.
  final FirebaseAuth auth;

  /// Firestore.
  final Firestore firestore;

  /// Ui auth service (native firebase_ui_auth screens or the basic ones).
  final FirebaseUiAuthService uiAuthService;

  /// Whether firestore rules are enforced (emulators) or not (local backend).
  final bool rulesEnforced;

  /// Context.
  ExampleFirebaseContext({
    required this.backendName,
    required this.app,
    required this.auth,
    required this.firestore,
    required this.uiAuthService,
    required this.rulesEnforced,
  });

  /// Sign in (or create) the hardcoded test user.
  Future<void> signInAsTestUser() async {
    await auth.signInOrUpWithEmailAndPassword(
      email: testUserEmail,
      password: testUserPassword,
    );
  }

  /// Close.
  Future<void> dispose() => app.delete();
}

/// Native Firebase is fully supported on these platforms.
bool get useNativeFirebase =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

/// Init the context for the current platform (native or REST).
Future<ExampleFirebaseContext> initExampleFirebaseContext() async {
  if (useNativeFirebase) {
    return initExampleFirebaseContextNative();
  }
  return initExampleFirebaseContextRest();
}

/// Native Firebase (web, android, ios, macos) on the emulators, with the
/// native firebase_ui_auth screens.
Future<ExampleFirebaseContext> initExampleFirebaseContextNative() async {
  await native.Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var app = firebaseFlutter.app();
  var auth = firebaseAuthServiceFlutter.auth(app) as FirebaseAuthFlutter;
  // automaticHostMapping maps localhost to 10.0.2.2 on the Android emulator.
  await auth.nativeInstance.useAuthEmulator(
    emulatorHost,
    authEmulatorPort,
    automaticHostMapping: true,
  );
  var firestore = firestoreServiceFlutter.firestore(app) as FirestoreFlutter;
  await firestore.useFirestoreEmulator(emulatorHost, firestoreEmulatorPort);

  const uiAuthService = FirebaseUiAuthServiceFlutter();
  uiAuthService.configureProviders(firebaseAuth: auth);
  return ExampleFirebaseContext(
    backendName: 'native',
    app: app,
    auth: auth,
    firestore: firestore,
    uiAuthService: uiAuthService,
    rulesEnforced: true,
  );
}

/// REST (linux, windows) on the emulators, with the basic screens.
Future<ExampleFirebaseContext> initExampleFirebaseContextRest() async {
  var app = await firebaseRest.initializeAppAsync(
    options: FirebaseAppOptions(
      projectId: emulatorProjectId,
      apiKey: emulatorApiKey,
    ),
  );
  var auth = firebaseAuthServiceRest.auth(app);
  await auth.useAuthEmulator(emulatorHost, authEmulatorPort);
  var firestore = firestoreServiceRest.firestore(app);
  await firestore.useFirestoreEmulator(emulatorHost, firestoreEmulatorPort);
  return ExampleFirebaseContext(
    backendName: 'rest',
    app: app,
    auth: auth,
    firestore: firestore,
    uiAuthService: firebaseUiAuthServiceBasic,
    rulesEnforced: true,
  );
}
