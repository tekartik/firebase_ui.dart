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

  /// Options.
  const FirebaseUiAuthOptions({
    this.registerEnabled = true,
    this.lostPasswordEnabled = true,
    this.linkAnonymousUser = true,
  });

  /// Copy with new values.
  FirebaseUiAuthOptions copyWith({
    bool? registerEnabled,
    bool? lostPasswordEnabled,
    bool? linkAnonymousUser,
  }) => FirebaseUiAuthOptions(
    registerEnabled: registerEnabled ?? this.registerEnabled,
    lostPasswordEnabled: lostPasswordEnabled ?? this.lostPasswordEnabled,
    linkAnonymousUser: linkAnonymousUser ?? this.linkAnonymousUser,
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
