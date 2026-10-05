import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';

import '../legacy_material.dart';

/// Lost password screen (native firebase_ui_auth [ForgotPasswordScreen]).
class AuthFlutterLostPasswordScreen extends StatelessWidget {
  /// Initial email.
  final String? email;

  /// Lost password screen
  const AuthFlutterLostPasswordScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    return legacyMaterialScreen(
      ForgotPasswordScreen(
        auth: bloc.firebaseAuth.nativeInstance,
        email: email,
      ),
    );
  }
}

/// Lost password screen
Widget authFlutterLostPasswordScreen({
  FirebaseAuth? firebaseAuth,
  String? email,
}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: AuthFlutterLostPasswordScreen(email: email),
);
