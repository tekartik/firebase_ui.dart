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

  /// Options.
  const FirebaseUiAuthOptions({
    this.registerEnabled = true,
    this.lostPasswordEnabled = true,
  });

  /// Copy with new values.
  FirebaseUiAuthOptions copyWith({
    bool? registerEnabled,
    bool? lostPasswordEnabled,
  }) => FirebaseUiAuthOptions(
    registerEnabled: registerEnabled ?? this.registerEnabled,
    lostPasswordEnabled: lostPasswordEnabled ?? this.lostPasswordEnabled,
  );

  @override
  String toString() =>
      'FirebaseUiAuthOptions(register: $registerEnabled, '
      'lostPassword: $lostPasswordEnabled)';
}

/// Default options (register and lost password enabled).
const firebaseUiAuthOptionsDefault = FirebaseUiAuthOptions();
