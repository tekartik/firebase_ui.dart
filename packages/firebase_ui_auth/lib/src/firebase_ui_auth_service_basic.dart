import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/src/firebase_ui_auth_options.dart';
import 'package:tekartik_firebase_ui_auth/src/firebase_ui_auth_service.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart' as impl;

/// Ui Auth service using the built-in material screens.
///
/// Prefer using the instance [firebaseUiAuthServiceBasic] unless you need
/// custom [options].
class FirebaseUiAuthServiceBasic implements FirebaseUiAuthService {
  @override
  final FirebaseUiAuthOptions options;

  /// Constructor
  const FirebaseUiAuthServiceBasic({
    this.options = firebaseUiAuthOptionsDefault,
  });

  @override
  Widget authScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authScreen(firebaseAuth: firebaseAuth, uiAuthService: this);

  @override
  Widget loginScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authLoginScreen(firebaseAuth: firebaseAuth, uiAuthService: this);

  @override
  Widget registerScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authRegisterScreen(firebaseAuth: firebaseAuth, uiAuthService: this);

  @override
  Widget lostPasswordScreen({FirebaseAuth? firebaseAuth, String? email}) =>
      impl.authLostPasswordScreen(
        firebaseAuth: firebaseAuth,
        uiAuthService: this,
        email: email,
      );

  @override
  Widget profileScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authProfileScreen(firebaseAuth: firebaseAuth, uiAuthService: this);

  @override
  Widget emailVerificationScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authEmailVerificationScreen(
        firebaseAuth: firebaseAuth,
        uiAuthService: this,
      );
}

/// FirebaseUiAuthServiceBasic instance
const firebaseUiAuthServiceBasic = FirebaseUiAuthServiceBasic();
