import 'package:dev_build/shell.dart';

/// Run the app on linux, using the REST backend (start the emulators first).
Future<void> main() async {
  await run('flutter run -d linux');
}
