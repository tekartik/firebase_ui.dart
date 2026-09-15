import 'package:dev_build/shell.dart';

/// The platform folders (web, linux) are not committed: regenerate them with
/// `flutter create`. Safe to run again.
Future<void> main() async {
  await run(
    'flutter create --no-pub --platforms=web,linux '
    '--org com.tekartik --project-name tekartik_firebase_ui_auth_sdb_example .',
  );
}
