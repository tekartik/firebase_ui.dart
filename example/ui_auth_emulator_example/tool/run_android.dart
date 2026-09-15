import 'package:dev_build/shell.dart';

/// Run the app on the connected android device or emulator (start the
/// firebase emulators first, localhost is mapped to 10.0.2.2 automatically).
Future<void> main() async {
  await run('flutter run -d android');
}
