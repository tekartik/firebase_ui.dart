import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_ui_auth/src/l10n/app_localizations.dart';
import 'package:tekartik_firebase_ui_auth/src/l10n/app_localizations_en.dart';

/// Get the current app intl
AppLocalizations appIntl(BuildContext context) {
  return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizationsEn();
}

/// Localization exported
typedef FirebaseUiAuthServiceBasicLocalizations = AppLocalizations;

/// Default localization exported
typedef FirebaseUiAuthServiceBasicLocalizationsDefault = AppLocalizationsEn;
