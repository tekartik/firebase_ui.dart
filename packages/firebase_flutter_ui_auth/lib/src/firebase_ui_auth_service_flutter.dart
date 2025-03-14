import 'package:firebase_ui_auth/firebase_ui_auth.dart' as native;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as native;
import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_flutter/firebase_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart' as impl;
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Ui Auth service on firebase flutter
/// prefer using the instance [firebaseUiAuthServiceFlutter]
class FirebaseUiAuthServiceFlutter implements FirebaseUiAuthService {
  /// Constructor
  const FirebaseUiAuthServiceFlutter();

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
      impl.authFlutterScreen(firebaseAuth: firebaseAuth);

  @override
  Widget loginScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authFlutterLoginScreen(firebaseAuth: firebaseAuth);

  @override
  Widget profileScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authFlutterProfileScreen(firebaseAuth: firebaseAuth);
}

/// FirebaseUiAuthServiceFlutter instance
const firebaseUiAuthServiceFlutter = FirebaseUiAuthServiceFlutter();
