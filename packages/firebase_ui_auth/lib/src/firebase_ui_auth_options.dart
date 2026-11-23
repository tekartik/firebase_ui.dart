import 'package:flutter/widgets.dart';

/// Deletes the account of the signed in user, see
/// [FirebaseUiAuthOptions.deleteAccount].
typedef FirebaseUiAuthDeleteAccount = Future<void> Function(
  BuildContext context,
);

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

  /// Deletes the account of the signed in user, the app way: its data on its
  /// server, then the user (an api call, the user deleted by the server).
  /// It confirms first and says what goes (its own dialog), and signs out
  /// once done.
  ///
  /// When set, the auth screen shows a "Delete account" row to a user with
  /// an account, and the "Delete account" button of the flutterfire profile
  /// screen runs it instead of deleting the auth user alone (which leaves
  /// the data of the user behind on the server). Null by default: no row,
  /// the flutterfire button deletes the auth user only.
  final FirebaseUiAuthDeleteAccount? deleteAccount;

  /// Options.
  const FirebaseUiAuthOptions({
    this.registerEnabled = true,
    this.lostPasswordEnabled = true,
    this.linkAnonymousUser = true,
    this.onAnonymousUserSignedIn,
    this.deleteAccount,
  });

  /// Copy with new values.
  FirebaseUiAuthOptions copyWith({
    bool? registerEnabled,
    bool? lostPasswordEnabled,
    bool? linkAnonymousUser,
    Future<void> Function(String anonymousIdToken)? onAnonymousUserSignedIn,
    FirebaseUiAuthDeleteAccount? deleteAccount,
  }) => FirebaseUiAuthOptions(
    registerEnabled: registerEnabled ?? this.registerEnabled,
    lostPasswordEnabled: lostPasswordEnabled ?? this.lostPasswordEnabled,
    linkAnonymousUser: linkAnonymousUser ?? this.linkAnonymousUser,
    onAnonymousUserSignedIn:
        onAnonymousUserSignedIn ?? this.onAnonymousUserSignedIn,
    deleteAccount: deleteAccount ?? this.deleteAccount,
  );

  @override
  String toString() =>
      'FirebaseUiAuthOptions(register: $registerEnabled, '
      'lostPassword: $lostPasswordEnabled, '
      'linkAnonymousUser: $linkAnonymousUser, '
      'deleteAccount: ${deleteAccount != null})';
}

/// Default options (register, lost password and anonymous user link
/// enabled).
const firebaseUiAuthOptionsDefault = FirebaseUiAuthOptions();
