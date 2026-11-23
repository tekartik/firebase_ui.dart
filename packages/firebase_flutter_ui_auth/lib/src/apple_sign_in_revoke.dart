import 'package:firebase_auth/firebase_auth.dart' as native;
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';

/// Revokes the Sign in with Apple tokens of the signed in user, what the App
/// Store asks of an account deletion (review guideline 5.1.1(v)): Apple asks
/// the user again (its sheet) for a fresh authorization code, handed to
/// firebase to revoke the tokens.
///
/// Returns false, asking nothing, when the user did not sign in with Apple.
/// Throws when the user cancels the Apple sheet or the revoke fails: the
/// caller deletes nothing then.
///
/// Call it before the account is deleted (the user must still exist), on
/// the auth of the app ([firebaseAuth], the default instance otherwise).
/// The native flow only: iOS and macOS, with the "Sign in with Apple"
/// capability (the provider of
/// `FirebaseUiAuthServiceFlutter.configureProviders(apple: true)`).
Future<bool> firebaseUiAuthRevokeAppleSignIn({
  FirebaseAuth? firebaseAuth,
}) async {
  var nativeAuth = firebaseAuth?.nativeInstance ?? native.FirebaseAuth.instance;
  var user = nativeAuth.currentUser;
  var providerId = native.AppleAuthProvider.PROVIDER_ID;
  if (user == null ||
      !user.providerData.any((info) => info.providerId == providerId)) {
    return false;
  }
  var credential = await user.reauthenticateWithProvider(
    native.AppleAuthProvider(),
  );
  var authorizationCode = credential.additionalUserInfo?.authorizationCode;
  if (authorizationCode == null) {
    throw StateError('Sign in with Apple gave no authorization code');
  }
  await nativeAuth.revokeTokenWithAuthorizationCode(authorizationCode);
  return true;
}
