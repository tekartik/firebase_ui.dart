import 'package:dev_build/shell.dart';

/// Run the app on chrome (start the emulators first).
Future<void> main() async {
  await run('flutter run -d chrome');
}
