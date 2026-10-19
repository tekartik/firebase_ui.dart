/// Options controlling which features the auth UI exposes.
///
/// Pass them to [FirebaseUiAuthServiceBasic] (or any other
/// `FirebaseUiAuthService` implementation):
///
/// ```dart
/// var uiAuthService = FirebaseUiAuthServiceBasic(
///   options: FirebaseUiAuthOptions(registerEnabled: false),
/// );
/// ```
class FirebaseUiAuthOptions {
  /// Whether users can create an account (sign up) from the login screen.
  ///
  /// When `false`, the "Sign up" link and the "Create account" button are
  /// hidden.
  final bool registerEnabled;

  /// Whether the login screen shows a "Forgot password?" link opening the
  /// lost password screen.
  final bool lostPasswordEnabled;

  /// Whether creating an account links it to an anonymous current user
  /// ([FirebaseUser.linkWithCredential]): the uid, and what the app saved
  /// under it, are kept. When `false` a new user is created (new uid).
  ///
  /// Signing in to an existing account always switches to it (its own uid):
  /// in this mode the login screen says so to an anonymous user.
  final bool linkAnonymousUser;

  /// Called once an anonymous user signed in to an existing account, with an
  /// id token of the anonymous user taken before: the app hands it to its
  /// server (`app-user/merge`) so that what they did follows them. In this
  /// mode the login screen says so to an anonymous user. A failure is
  /// ignored (the sign in succeeded).
  final Future<void> Function(String anonymousIdToken)? onAnonymousUserSignedIn;

  /// Options.
  const FirebaseUiAuthOptions({
    this.registerEnabled = true,
    this.lostPasswordEnabled = true,
    this.linkAnonymousUser = true,
    this.onAnonymousUserSignedIn,
  });

  /// Copy with new values.
  FirebaseUiAuthOptions copyWith({
    bool? registerEnabled,
    bool? lostPasswordEnabled,
    bool? linkAnonymousUser,
    Future<void> Function(String anonymousIdToken)? onAnonymousUserSignedIn,
  }) => FirebaseUiAuthOptions(
    registerEnabled: registerEnabled ?? this.registerEnabled,
    lostPasswordEnabled: lostPasswordEnabled ?? this.lostPasswordEnabled,
    linkAnonymousUser: linkAnonymousUser ?? this.linkAnonymousUser,
    onAnonymousUserSignedIn:
        onAnonymousUserSignedIn ?? this.onAnonymousUserSignedIn,
  );

  @override
  String toString() =>
      'FirebaseUiAuthOptions(register: $registerEnabled, '
      'lostPassword: $lostPasswordEnabled, '
      'linkAnonymousUser: $linkAnonymousUser)';
}

/// Default options (register, lost password and anonymous user link
/// enabled).
const firebaseUiAuthOptionsDefault = FirebaseUiAuthOptions();
