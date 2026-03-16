// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authTitle => 'Authentication';

  @override
  String get authUserEmailCopiedToClipboard => 'User email copied to clipboard';

  @override
  String get authUserEmailLabel => 'User Email';

  @override
  String get authUserIdCopiedToClipboard => 'User id copied to clipboard';

  @override
  String get authUserIdLabel => 'User ID';

  @override
  String get emailNotVerifiedMessage => 'Email not verified';

  @override
  String get emailVerificationButtonLabel => 'Verify email';

  @override
  String get emailVerifiedMessage => 'Email verified';

  @override
  String hello(String userName) {
    return 'Hello $userName';
  }

  @override
  String get loginButtonLabel => 'Login';

  @override
  String get loginGenericError => 'Login failed';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginUserLabel => 'User';

  @override
  String get logoutButtonLabel => 'Logout';

  @override
  String get profileButtonLabel => 'Profile';

  @override
  String profileLoggedInAs(String email) {
    return 'Logged in as $email';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get signInWithGoogleButtonLabel => 'Sign in with Google';
}
