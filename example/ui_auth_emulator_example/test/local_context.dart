import 'package:tekartik_app_flutter_idb/sdb.dart';
import 'package:tekartik_firebase_auth_sdb/auth_sdb.dart';
import 'package:tekartik_firebase_firestore_sembast/firestore_sembast.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';
import 'package:tekartik_firebase_ui_auth_emulator_example/firebase_context.dart';

/// In-memory backend (no emulator, rules not enforced) for widget tests.
ExampleFirebaseContext initExampleFirebaseContextLocal() {
  var app = newFirebaseAppLocal();
  var auth = FirebaseAuthServiceSdb(sdbFactory: sdbFactoryMemory).auth(app);
  var firestore = newFirestoreServiceMemory().firestore(app);
  return ExampleFirebaseContext(
    backendName: 'local',
    app: app,
    auth: auth,
    firestore: firestore,
    uiAuthService: firebaseUiAuthServiceBasic,
    rulesEnforced: false,
  );
}
