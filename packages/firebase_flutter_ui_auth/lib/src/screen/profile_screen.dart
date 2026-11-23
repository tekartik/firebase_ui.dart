import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// firebase_ui_auth screens are still legacy material.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy show AppBar;
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_bloc/bloc_provider.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_firebase_auth_flutter/auth_flutter.dart';
import 'package:tekartik_firebase_flutter_ui_auth/src/utils/app_intl.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

import '../firebase_ui_auth_service_flutter.dart';
import '../legacy_material.dart';
import 'auth_screen_utils.dart';

// ignore: unused_import, depend_on_referenced_packages

/// Auth profile screen
class AuthFlutterProfileScreen extends StatefulWidget {
  /// What the "Delete account" button runs, the app way (its server data
  /// too, see [FirebaseUiAuthOptions.deleteAccount]); null, the flutterfire
  /// default: the auth user alone is deleted.
  final FirebaseUiAuthDeleteAccount? deleteAccount;

  /// Auth profile screen
  const AuthFlutterProfileScreen({super.key, this.deleteAccount});

  @override
  State<AuthFlutterProfileScreen> createState() =>
      _AuthFlutterProfileScreenState();
}

class _AuthFlutterProfileScreenState extends State<AuthFlutterProfileScreen>
    with BusyScreenStateMixin<AuthFlutterProfileScreen> {
  @override
  void dispose() {
    busyDispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    firebaseUiAuthEnsureProviders();

    // The only pop on sign out (no SignedOutAction: upstream calls it right
    // after its sign out, popping a second time, the hub too).
    authFlutterScreenPopWhen(this, when: (authState) => !authState.signedIn);
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<AuthScreenBloc>(context);
    var intl = appIntl(context);
    // Not rebuilt on auth state changes: upstream ProfileScreen reads
    // `auth.currentUser!`, a rebuild on the signed out state (during the exit
    // transition) throws.
    var deleteAccount = widget.deleteAccount;
    return legacyMaterialScreen(
      ProfileScreen(
        appBar: legacy.AppBar(title: Text(intl.profileTitle)),
        auth: bloc.firebaseAuth.nativeInstance,
        // The app deletes the account: its "confirmation" does it all
        // (confirm, server, sign out) and answers false, the button then
        // never deletes the auth user alone.
        showDeleteConfirmationDialog: deleteAccount != null,
        deleteConfirmation: deleteAccount == null
            ? null
            : (context) async {
                await deleteAccount(context);
                return false;
              },
      ),
    );
  }
}

/// Auth profile screen, see [AuthFlutterProfileScreen.deleteAccount].
Widget authFlutterProfileScreen({
  FirebaseAuth? firebaseAuth,
  FirebaseUiAuthDeleteAccount? deleteAccount,
}) => BlocProvider(
  blocBuilder: () => AuthScreenBloc(firebaseAuth: firebaseAuth),
  child: AuthFlutterProfileScreen(deleteAccount: deleteAccount),
);
