import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_auth/auth.dart';

import 'firebase_ui_auth_options.dart';

/// Ui Auth service
///
/// Builds the screens of the authentication flow. Screens are plain widgets
/// meant to be pushed on a [Navigator].
abstract class FirebaseUiAuthService {
  /// Options (register, lost password...)
  FirebaseUiAuthOptions get options;

  /// Base auth screen, allowing login and profile
  Widget authScreen({FirebaseAuth? firebaseAuth});

  /// Login/Sign-in
  Widget loginScreen({FirebaseAuth? firebaseAuth});

  /// Register/Sign-up (email and password).
  ///
  /// Only reachable from the UI when [FirebaseUiAuthOptions.registerEnabled]
  /// is `true`.
  Widget registerScreen({FirebaseAuth? firebaseAuth});

  /// Lost password: sends a password reset email.
  ///
  /// [email] pre-fills the form.
  Widget lostPasswordScreen({FirebaseAuth? firebaseAuth, String? email});

  /// Profile
  Widget profileScreen({FirebaseAuth? firebaseAuth});

  /// Email verification
  Widget emailVerificationScreen({FirebaseAuth? firebaseAuth});
}
