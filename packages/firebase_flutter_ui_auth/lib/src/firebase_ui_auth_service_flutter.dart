import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart' as impl;
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Ui Auth service
class FirebaseUiAuthServiceFlutter implements FirebaseUiAuthService {
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
