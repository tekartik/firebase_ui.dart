import 'package:flutter/material.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Auth screen
class AuthFlutterScreen extends AuthScreen {
  /// Auth screen
  const AuthFlutterScreen({
    super.key,
    super.uiAuthService = firebaseUiAuthServiceFlutter,
  });
}

/// Auth screen
Widget authFlutterScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: const AuthFlutterScreen(),
);
