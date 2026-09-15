import 'package:dev_build/shell.dart';
import 'package:tekartik_firebase_ui_auth_emulator_example/emulator_config.dart';

/// Start the auth and firestore emulators (Ctrl+C to stop).
///
/// Requires the firebase CLI (`npm install -g firebase-tools`) and java.
/// The emulator UI is then available at http://localhost:4000.
Future<void> main() async {
  var shell = Shell(workingDirectory: 'emulator');
  await shell.run(
    'firebase emulators:start --only auth,firestore --project $emulatorProjectId',
  );
}
