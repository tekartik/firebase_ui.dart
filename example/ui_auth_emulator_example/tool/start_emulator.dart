import 'dart:convert';
import 'dart:io';

import 'package:tekartik_firebase_tools_common/firebase_emulator.dart';
import 'package:tekartik_firebase_ui_auth_emulator_example/emulator_config.dart';

/// Start the auth and firestore emulators of `emulator/` (Ctrl+C to stop).
///
/// Requires the firebase CLI (`npm install -g firebase-tools`) and java.
/// Waits until the emulators are ready; if they are already running (an
/// emulator hub answers on localhost:4400), says so and exits.
/// The emulator UI is then available at http://localhost:4000.
Future<void> main() async {
  _ensureFirebaseRc();
  var service = FirebaseEmulatorService(path: 'emulator');
  if (!await service.isSupported()) {
    stderr.writeln(
      'firebase emulator not supported: needs the firebase CLI 15.14+'
      ' (npm install -g firebase-tools)',
    );
    exit(1);
  }
  var emulator = await service.start(
    options: FirebaseEmulatorOptions(
      projectId: emulatorProjectId,
      onlyAuth: true,
      onlyFirestore: true,
    ),
  );
  if (emulator is FirebaseRunningEmulator) {
    stdout.writeln('Emulators already running');
    return;
  }
  stdout.writeln(
    'Emulators ready, UI at http://$emulatorHost:$emulatorUiPort'
    ' (Ctrl+C to stop)',
  );
  await ProcessSignal.sigint.watch().first;
  await emulator.stop();
}

/// Writes `emulator/.firebaserc` from [emulatorProjectId] when missing.
///
/// The firebase folder helpers expect one, and dotfiles are not committed in
/// this repository, so the script creates it on a fresh clone.
void _ensureFirebaseRc() {
  var file = File('emulator/.firebaserc');
  if (!file.existsSync()) {
    var content = const JsonEncoder.withIndent('  ').convert({
      'projects': {'default': emulatorProjectId},
    });
    file.writeAsStringSync('$content\n');
  }
}
