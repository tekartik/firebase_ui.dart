import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_auth/auth.dart';
import 'package:tekartik_firebase_ui_auth/src/firebase_ui_auth_service.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart' as impl;

/// Ui Auth service
class FirebaseUiAuthServiceBasic implements FirebaseUiAuthService {
  @override
  Widget authScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authScreen(firebaseAuth: firebaseAuth);
  @override
  Widget loginScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authLoginScreen(firebaseAuth: firebaseAuth);
  @override
  Widget profileScreen({FirebaseAuth? firebaseAuth}) =>
      impl.authProfileScreen(firebaseAuth: firebaseAuth);
}
