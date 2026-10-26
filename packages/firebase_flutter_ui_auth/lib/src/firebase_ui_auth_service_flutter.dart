import 'package:firebase_ui_auth/firebase_ui_auth.dart' as native;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'
    as native;
import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_flutter/firebase_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart' as impl;
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// The providers [FirebaseUiAuthServiceFlutter.configureProviders] asked
/// for, configured by the first auth screen
/// ([firebaseUiAuthEnsureProviders]).
void Function()? _pendingProviders;

/// Configures the providers asked by
/// [FirebaseUiAuthServiceFlutter.configureProviders], once: called by the
/// auth screens before they build.
void firebaseUiAuthEnsureProviders() {
  var configure = _pendingProviders;
  if (configure != null) {
    _pendingProviders = null;
    configure();
  }
}

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

  /// Configure email provider by default, Google with [googleAuthClientId].
  ///
  /// Lazy: the providers are configured by the first auth screen (sign in,
  /// register, profile...), not here. Google's provider starts Google
  /// Sign-In (on the web its `g_state` cookie), so nothing of it runs before
  /// the user opens an auth screen (GDPR).
  void configureProviders({
    FirebaseAuth? firebaseAuth,
    bool noEmailPassword = false,
    String? googleAuthClientId,
  }) {
    _pendingProviders = () {
      native.FirebaseUIAuth.configureProviders([
        if (!noEmailPassword) native.EmailAuthProvider(),
        if (googleAuthClientId != null)
          native.GoogleProvider(clientId: googleAuthClientId),
      ], app: firebaseAuth?.app.nativeInstance);
    };
  }

  @override
  Widget authScreen({
    FirebaseAuth? firebaseAuth,
    FirebaseUiAuthContinue? authContinue,
  }) => impl.authFlutterScreen(
    firebaseAuth: firebaseAuth,
    uiAuthService: this,
    authContinue: authContinue,
  );

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
