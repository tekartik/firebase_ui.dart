import 'package:firebase_ui_auth/firebase_ui_auth.dart' as native;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as native;
import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_flutter/firebase_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart' as impl;
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Ui Auth service on firebase flutter (native firebase_ui_auth screens).
///
/// Prefer using the instance [firebaseUiAuthServiceFlutter] unless you need
/// custom [options].
class FirebaseUiAuthServiceFlutter implements FirebaseUiAuthService {
  @override
  final FirebaseUiAuthOptions options;

  /// Constructor
  const FirebaseUiAuthServiceFlutter({
    this.options = firebaseUiAuthOptionsDefault,
  });

  /// Configure email provider by default.
  void configureProviders({
    FirebaseAuth? firebaseAuth,
    bool noEmailPassword = false,
    String? googleAuthClientId,
  }) {
    native.FirebaseUIAuth.configureProviders([
      if (!noEmailPassword) native.EmailAuthProvider(),
      if (googleAuthClientId != null)
        native.GoogleProvider(clientId: googleAuthClientId),
    ], app: firebaseAuth?.app.nativeInstance);
  }

  @override
  Widget authScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authFlutterScreen(firebaseAuth: firebaseAuth, uiAuthService: this);

  @override
  Widget loginScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authFlutterLoginScreen(firebaseAuth: firebaseAuth, options: options);

  @override
  Widget registerScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authFlutterRegisterScreen(firebaseAuth: firebaseAuth);

  @override
  Widget lostPasswordScreen({FirebaseAuth? firebaseAuth, String? email}) => impl
      .authFlutterLostPasswordScreen(firebaseAuth: firebaseAuth, email: email);

  @override
  Widget profileScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authFlutterProfileScreen(firebaseAuth: firebaseAuth);

  @override
  Widget emailVerificationScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authFlutterEmailVerificationScreen(firebaseAuth: firebaseAuth);
}

/// FirebaseUiAuthServiceFlutter instance
const firebaseUiAuthServiceFlutter = FirebaseUiAuthServiceFlutter();
