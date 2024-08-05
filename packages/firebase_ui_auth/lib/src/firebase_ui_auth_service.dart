import 'package:flutter/widgets.dart';
import 'package:tekartik_firebase_auth/auth.dart';

/// Ui Auth service
abstract class FirebaseUiAuthService {
  /// Base auth screen, allowing login and profile
  Widget authScreen({FirebaseAuth? firebaseAuth});

  /// Login/Sign-in
  Widget loginScreen({FirebaseAuth? firebaseAuth});

  /// Profile
  Widget profileScreen({FirebaseAuth? firebaseAuth});
}
