import 'dart:io';

import 'package:dev_build/shell.dart';
import 'package:path/path.dart';

/// The platform folders (android, ios, macos, linux, web) are not committed:
/// regenerate them with `flutter create` and re-apply the tweaks the
/// emulators need (cleartext HTTP on Android, network client entitlement on
/// macOS). Safe to run again.
Future<void> main() async {
  await run(
    'flutter create --no-pub --platforms=web,android,ios,macos,linux '
    '--org com.tekartik --project-name tekartik_firebase_ui_auth_emulator_example .',
  );

  // Android: the emulators are plain http on 10.0.2.2.
  _patch(
    join('android', 'app', 'src', 'main', 'AndroidManifest.xml'),
    marker: 'android:usesCleartextTraffic',
    replace: '        android:icon="@mipmap/ic_launcher">',
    with_:
        '        android:icon="@mipmap/ic_launcher"\n'
        '        android:usesCleartextTraffic="true">',
  );

  // macOS: the sandbox needs the network client entitlement.
  for (var file in ['DebugProfile.entitlements', 'Release.entitlements']) {
    _patch(
      join('macos', 'Runner', file),
      marker: 'com.apple.security.network.client',
      replace: '\t<key>com.apple.security.app-sandbox</key>\n\t<true/>\n',
      with_:
          '\t<key>com.apple.security.app-sandbox</key>\n\t<true/>\n'
          '\t<key>com.apple.security.network.client</key>\n\t<true/>\n',
    );
  }
}

void _patch(
  String path, {
  required String marker,
  required String replace,
  required String with_,
}) {
  var file = File(path);
  var content = file.readAsStringSync();
  if (content.contains(marker)) {
    stdout.writeln('$path: already patched');
    return;
  }
  if (!content.contains(replace)) {
    stderr.writeln('$path: pattern not found, patch it by hand');
    return;
  }
  file.writeAsStringSync(content.replaceFirst(replace, with_));
  stdout.writeln('$path: patched');
}
