import 'package:material_ui/material_ui.dart';
import 'package:tekartik_firebase_auth/auth.dart';

import 'firebase_ui_auth_service.dart';

/// The auth screen opened to do something once signed in ("Sign in and
/// join"): signed in, it shows a [label] button. The screen pops with a
/// [FirebaseUiAuthContinueResult], whether the user tapped it or went back.
///
/// The caller does the action when [FirebaseUiAuthContinueResult.continued]
/// (join) and otherwise stays where it was: a user who signed in before going
/// back ([FirebaseUiAuthContinueResult.hasAccount]) finds the action itself
/// there ("Join" instead of "Sign in and join").
class FirebaseUiAuthContinue {
  /// The button label ("Join"), "Continue" when null.
  final String? label;

  /// Continue button of the auth screen.
  const FirebaseUiAuthContinue({this.label});

  @override
  String toString() => 'FirebaseUiAuthContinue($label)';
}

/// How the auth screen opened with a [FirebaseUiAuthContinue] closed.
class FirebaseUiAuthContinueResult {
  /// The current user when the screen closed, null when signed out. An
  /// anonymous user has no account ([hasAccount]).
  final User? user;

  /// Whether the user tapped the continue button (signed in to an account),
  /// `false` when they went back.
  final bool continued;

  /// Result.
  const FirebaseUiAuthContinueResult({
    required this.user,
    required this.continued,
  });

  /// Whether a user is signed in to an account (not anonymous): always when
  /// [continued], possibly after going back.
  bool get hasAccount => !(user?.isAnonymous ?? true);

  @override
  String toString() =>
      'FirebaseUiAuthContinueResult(${user?.uid}, continued: $continued)';
}

/// Continue helpers.
extension FirebaseUiAuthServiceContinueExt on FirebaseUiAuthService {
  /// Pushes the auth screen with [authContinue] and returns how it closed.
  Future<FirebaseUiAuthContinueResult> pushAuthScreenToContinue(
    BuildContext context, {
    FirebaseAuth? firebaseAuth,
    FirebaseUiAuthContinue authContinue = const FirebaseUiAuthContinue(),
  }) async {
    var result = await Navigator.of(context).push<FirebaseUiAuthContinueResult>(
      MaterialPageRoute(
        builder: (_) =>
            authScreen(firebaseAuth: firebaseAuth, authContinue: authContinue),
      ),
    );
    // Removed by the app (no result): as going back.
    return result ??
        FirebaseUiAuthContinueResult(
          user: (firebaseAuth ?? FirebaseAuth.instance).currentUser,
          continued: false,
        );
  }
}
