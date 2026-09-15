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
  String get authWelcomeHeadline => 'Welcome';

  @override
  String get authWelcomeSubtitle => 'Sign in to access your account';

  @override
  String get authCreateAccountButtonLabel => 'Create account';

  @override
  String get authVerifiedBadge => 'Verified';

  @override
  String get authActiveSession => 'Active session';

  @override
  String get authAnonymousUser => 'Anonymous user';

  @override
  String get authAccountDetailsSection => 'Account details';

  @override
  String get authPreferencesSection => 'Preferences';

  @override
  String get authUserEmailCopiedToClipboard => 'User email copied to clipboard';

  @override
  String get authUserEmailLabel => 'Account email';

  @override
  String get authPrimaryBadge => 'Primary';

  @override
  String get authUserIdCopiedToClipboard => 'User id copied to clipboard';

  @override
  String get authUserIdLabel => 'User ID';

  @override
  String get authSecurityStatusLabel => 'Security & status';

  @override
  String get authConfirmedBadge => 'Confirmed';

  @override
  String get authPendingBadge => 'Pending';

  @override
  String get authSessionProviderLabel => 'Session provider';

  @override
  String get copyTooltip => 'Copy';

  @override
  String get emailNotVerifiedMessage => 'Email not verified';

  @override
  String get emailVerificationButtonLabel => 'Verify email';

  @override
  String get emailVerificationRowSubtitle => 'Confirm your email address';

  @override
  String get emailVerifiedMessage => 'Email verified';

  @override
  String get emailVerificationTitle => 'Email verification';

  @override
  String get emailVerificationHeadline => 'Verify your email';

  @override
  String emailVerificationSubtitle(String email) {
    return 'We need to confirm that $email belongs to you. Send yourself a verification email and follow the link it contains.';
  }

  @override
  String get emailVerificationSendButtonLabel => 'Send verification email';

  @override
  String get emailVerificationSentMessage =>
      'Verification email sent. Check your inbox.';

  @override
  String get emailVerificationCheckButtonLabel => 'I have verified my email';

  @override
  String get emailVerificationNotYetVerifiedMessage =>
      'Your email is not verified yet.';

  @override
  String get emailVerificationGenericError =>
      'Could not send the verification email.';

  @override
  String hello(String userName) {
    return 'Hello $userName';
  }

  @override
  String get loginTitle => 'Account access';

  @override
  String get loginHeadline => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Please enter your details to sign in to your account';

  @override
  String get loginUserLabel => 'Email or username';

  @override
  String get loginUserHint => 'name@example.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginForgotPasswordLink => 'Forgot password?';

  @override
  String get loginButtonLabel => 'Sign in';

  @override
  String get loginOrContinueWith => 'Or continue with';

  @override
  String get loginNoAccountText => 'Don\'t have an account?';

  @override
  String get loginSignUpLink => 'Sign up';

  @override
  String get loginGenericError =>
      'Sign in failed. Please check your credentials and try again.';

  @override
  String get logoutButtonLabel => 'Logout session';

  @override
  String get passwordShowTooltip => 'Show password';

  @override
  String get passwordHideTooltip => 'Hide password';

  @override
  String get profileButtonLabel => 'Profile';

  @override
  String get profileRowSubtitle => 'View your account information';

  @override
  String profileLoggedInAs(String email) {
    return 'Logged in as $email';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get registerTitle => 'Sign up';

  @override
  String get registerHeadline => 'Create your account';

  @override
  String get registerSubtitle =>
      'Enter your email and choose a password to get started';

  @override
  String get registerPasswordConfirmLabel => 'Confirm password';

  @override
  String get registerPasswordMismatchError => 'Passwords do not match';

  @override
  String get registerButtonLabel => 'Sign up';

  @override
  String get registerHaveAccountText => 'Already have an account?';

  @override
  String get registerSignInLink => 'Sign in';

  @override
  String get registerGenericError =>
      'Account creation failed. Please try again.';

  @override
  String get lostPasswordTitle => 'Reset password';

  @override
  String get lostPasswordHeadline => 'Forgot your password?';

  @override
  String get lostPasswordSubtitle =>
      'Enter the email of your account and we will send you a link to reset your password';

  @override
  String get lostPasswordButtonLabel => 'Send reset link';

  @override
  String get lostPasswordSentTitle => 'Check your inbox';

  @override
  String lostPasswordSentMessage(String email) {
    return 'If an account exists for $email, a password reset link has been sent.';
  }

  @override
  String get lostPasswordBackToSignInLink => 'Back to sign in';

  @override
  String get lostPasswordGenericError =>
      'Could not send the reset email. Please check the address and try again.';

  @override
  String get signInWithGoogleButtonLabel => 'Sign in with Google';

  @override
  String get googleButtonLabel => 'Google';

  @override
  String get googleSignInLinkMessage =>
      'Please sign in using the following link:';

  @override
  String get copyLinkButtonLabel => 'Copy link';

  @override
  String get doneButtonLabel => 'Done';
}
