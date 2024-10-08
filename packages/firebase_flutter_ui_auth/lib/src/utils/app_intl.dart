import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Localization
FirebaseUiAuthServiceBasicLocalizations appIntl(BuildContext context) {
  return Localizations.of<FirebaseUiAuthServiceBasicLocalizations>(
          context, FirebaseUiAuthServiceBasicLocalizations) ??
      FirebaseUiAuthServiceBasicLocalizationsDefault();
}
