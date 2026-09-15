import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The authentication screen title
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authTitle;

  /// Headline of the authentication screen when signed out
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcomeHeadline;

  /// Subtitle of the authentication screen when signed out
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account'**
  String get authWelcomeSubtitle;

  /// Button opening the registration screen
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountButtonLabel;

  /// Badge shown next to the user name when the email is verified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get authVerifiedBadge;

  /// Status line shown in the user header card
  ///
  /// In en, this message translates to:
  /// **'Active session'**
  String get authActiveSession;

  /// Name shown for an anonymous user
  ///
  /// In en, this message translates to:
  /// **'Anonymous user'**
  String get authAnonymousUser;

  /// Section title above the account details card
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get authAccountDetailsSection;

  /// Section title above the preferences card
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get authPreferencesSection;

  /// The authentication screen user email copied to clipboard message
  ///
  /// In en, this message translates to:
  /// **'User email copied to clipboard'**
  String get authUserEmailCopiedToClipboard;

  /// The label for the account email row
  ///
  /// In en, this message translates to:
  /// **'Account email'**
  String get authUserEmailLabel;

  /// Badge shown next to the account email
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get authPrimaryBadge;

  /// The authentication screen user id copied to clipboard message
  ///
  /// In en, this message translates to:
  /// **'User id copied to clipboard'**
  String get authUserIdCopiedToClipboard;

  /// The label for the user id row
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get authUserIdLabel;

  /// The label for the email verification status row
  ///
  /// In en, this message translates to:
  /// **'Security & status'**
  String get authSecurityStatusLabel;

  /// Badge shown when the email is verified
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get authConfirmedBadge;

  /// Badge shown when the email is not verified
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get authPendingBadge;

  /// The label for the sign-in provider row
  ///
  /// In en, this message translates to:
  /// **'Session provider'**
  String get authSessionProviderLabel;

  /// Tooltip of the copy buttons
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyTooltip;

  /// Email not verified message
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerifiedMessage;

  /// The email verification button label
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get emailVerificationButtonLabel;

  /// Subtitle of the verify email preference row
  ///
  /// In en, this message translates to:
  /// **'Confirm your email address'**
  String get emailVerificationRowSubtitle;

  /// Email verified message
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerifiedMessage;

  /// The email verification screen title
  ///
  /// In en, this message translates to:
  /// **'Email verification'**
  String get emailVerificationTitle;

  /// The email verification screen headline
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get emailVerificationHeadline;

  /// The email verification screen subtitle
  ///
  /// In en, this message translates to:
  /// **'We need to confirm that {email} belongs to you. Send yourself a verification email and follow the link it contains.'**
  String emailVerificationSubtitle(String email);

  /// Button sending the verification email
  ///
  /// In en, this message translates to:
  /// **'Send verification email'**
  String get emailVerificationSendButtonLabel;

  /// Message shown once the verification email is sent
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Check your inbox.'**
  String get emailVerificationSentMessage;

  /// Button reloading the user to check the verification status
  ///
  /// In en, this message translates to:
  /// **'I have verified my email'**
  String get emailVerificationCheckButtonLabel;

  /// Message shown when the email is still not verified after a check
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified yet.'**
  String get emailVerificationNotYetVerifiedMessage;

  /// Error shown when sending the verification email fails
  ///
  /// In en, this message translates to:
  /// **'Could not send the verification email.'**
  String get emailVerificationGenericError;

  /// A message with a single parameter
  ///
  /// In en, this message translates to:
  /// **'Hello {userName}'**
  String hello(String userName);

  /// The login screen title
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get loginTitle;

  /// The login screen headline
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginHeadline;

  /// The login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Please enter your details to sign in to your account'**
  String get loginSubtitle;

  /// The login screen user label
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get loginUserLabel;

  /// The login screen user field hint
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get loginUserHint;

  /// The login screen password label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// Link opening the lost password screen
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPasswordLink;

  /// The login button label
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButtonLabel;

  /// Divider text above the third party sign-in buttons
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get loginOrContinueWith;

  /// Text before the sign up link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccountText;

  /// Link opening the registration screen
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUpLink;

  /// The login screen generic error message
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please check your credentials and try again.'**
  String get loginGenericError;

  /// The logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout session'**
  String get logoutButtonLabel;

  /// Tooltip of the password visibility toggle
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShowTooltip;

  /// Tooltip of the password visibility toggle
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHideTooltip;

  /// The profile button label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileButtonLabel;

  /// Subtitle of the profile preference row
  ///
  /// In en, this message translates to:
  /// **'View your account information'**
  String get profileRowSubtitle;

  /// The profile screen logged in as label
  ///
  /// In en, this message translates to:
  /// **'Logged in as {email}'**
  String profileLoggedInAs(String email);

  /// The profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// The registration screen title
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerTitle;

  /// The registration screen headline
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerHeadline;

  /// The registration screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your email and choose a password to get started'**
  String get registerSubtitle;

  /// The registration screen password confirmation label
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerPasswordConfirmLabel;

  /// Error shown when the two passwords differ
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordMismatchError;

  /// The registration button label
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerButtonLabel;

  /// Text before the sign in link
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHaveAccountText;

  /// Link going back to the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignInLink;

  /// The registration screen generic error message
  ///
  /// In en, this message translates to:
  /// **'Account creation failed. Please try again.'**
  String get registerGenericError;

  /// The lost password screen title
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get lostPasswordTitle;

  /// The lost password screen headline
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get lostPasswordHeadline;

  /// The lost password screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter the email of your account and we will send you a link to reset your password'**
  String get lostPasswordSubtitle;

  /// Button sending the password reset email
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get lostPasswordButtonLabel;

  /// Title shown once the reset email is sent
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get lostPasswordSentTitle;

  /// Message shown once the reset email is sent
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, a password reset link has been sent.'**
  String lostPasswordSentMessage(String email);

  /// Link going back to the login screen
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get lostPasswordBackToSignInLink;

  /// The lost password screen generic error message
  ///
  /// In en, this message translates to:
  /// **'Could not send the reset email. Please check the address and try again.'**
  String get lostPasswordGenericError;

  /// The sign in with google button label
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogleButtonLabel;

  /// The short label of the Google button
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get googleButtonLabel;

  /// Message of the dialog showing the Google sign in link
  ///
  /// In en, this message translates to:
  /// **'Please sign in using the following link:'**
  String get googleSignInLinkMessage;

  /// Button copying the sign in link
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLinkButtonLabel;

  /// Button closing a dialog
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButtonLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
