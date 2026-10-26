import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart' as legacy show AppBar, Scaffold;
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_rx_utils/app_rx_utils.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_flutter_ui_auth/ui_auth.dart';

import '../firebase_ui_auth_service_flutter.dart';
import '../legacy_material.dart';
import 'auth_screen_utils.dart';

/// Auth register screen (native firebase_ui_auth [RegisterScreen]).
///
/// The native screen has no app bar and the sign-in switch is hidden, so an
/// [AppBar] (with its back button) is added on top of it to allow leaving
/// the screen.
class AuthFlutterRegisterScreen extends StatefulWidget {
  /// Auth register screen
  const AuthFlutterRegisterScreen({super.key});

  @override
  State<AuthFlutterRegisterScreen> createState() =>
      _AuthFlutterRegisterScreenState();
}

class _AuthFlutterRegisterScreenState extends State<AuthFlutterRegisterScreen> {
  @override
  void initState() {
    super.initState();
    firebaseUiAuthEnsureProviders();

    authFlutterScreenPopWhen(
      this,
      // Not for an anonymous user: they came to get an account.
      when: (authState) => authState.hasAccount,
    );
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    var intl = appIntl(context);
    return ValueStreamBuilder(
      stream: bloc.state,
      builder: (context, snapshot) {
        return legacyMaterialScreen(
          legacy.Scaffold(
            appBar: legacy.AppBar(title: Text(intl.registerTitle)),
            body: RegisterScreen(
              auth: bloc.firebaseAuth.nativeInstance,
              showAuthActionSwitch: false,
              // Same as the sign in screen: upstream also offers Google here
              // and links an anonymous user.
              actions: authFlutterAccountActions(bloc),
            ),
          ),
        );
      },
    );
  }
}

/// Auth register screen
Widget authFlutterRegisterScreen({FirebaseAuth? firebaseAuth}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: const AuthFlutterRegisterScreen(),
);
