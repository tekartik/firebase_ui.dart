import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tekartik_app_flutter_idb/sdb.dart';
import 'package:tekartik_firebase_auth_sdb/auth_sdb.dart';
import 'package:tekartik_firebase_local/firebase_local.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Package name used for the local database.
const packageName = 'com.tekartik.firebase_ui_auth_sdb_example';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseAuth = initFirebaseAuthSdb(
    sdbFactory: getSdbFactory(packageName: packageName),
  );
  runApp(ExampleApp(firebaseAuth: firebaseAuth));
}

/// Create a local firebase app with an auth service backed by sdb.
FirebaseAuth initFirebaseAuthSdb({required SdbFactory sdbFactory}) {
  var app = newFirebaseAppLocal(
    options: FirebaseAppOptions(projectId: 'ui-auth-sdb-example'),
  );
  var authService = FirebaseAuthServiceSdb(sdbFactory: sdbFactory);
  return authService.auth(app);
}

/// Example app.
class ExampleApp extends StatelessWidget {
  /// The auth instance.
  final FirebaseAuth firebaseAuth;

  /// Example app.
  const ExampleApp({super.key, required this.firebaseAuth});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF5B4FE9);
    return MaterialApp(
      title: 'UI auth sdb example',
      theme: ThemeData(
        colorSchemeSeed: seedColor,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
      ),
      localizationsDelegates: const [
        FirebaseUiAuthServiceBasicLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales:
          FirebaseUiAuthServiceBasicLocalizations.supportedLocales,
      home: HomeScreen(firebaseAuth: firebaseAuth),
    );
  }
}

/// Home screen: current user and entry points to the auth screens.
class HomeScreen extends StatefulWidget {
  /// The auth instance.
  final FirebaseAuth firebaseAuth;

  /// Home screen.
  const HomeScreen({super.key, required this.firebaseAuth});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _registerEnabled = true;
  var _lostPasswordEnabled = true;

  FirebaseAuth get firebaseAuth => widget.firebaseAuth;

  FirebaseUiAuthService get uiAuthService => FirebaseUiAuthServiceBasic(
    options: FirebaseUiAuthOptions(
      registerEnabled: _registerEnabled,
      lostPasswordEnabled: _lostPasswordEnabled,
    ),
  );

  void _push(Widget Function() builder) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => builder()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UI auth sdb example')),
      body: StreamBuilder<User?>(
        stream: firebaseAuth.onCurrentUser,
        builder: (context, snapshot) {
          var user = snapshot.data;
          var signedIn = user != null;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(
                    signedIn ? Icons.verified_user : Icons.person_off_outlined,
                  ),
                  title: Text(
                    signedIn ? (user.email ?? user.uid) : 'Not signed in',
                  ),
                  subtitle: signedIn ? Text(user.uid) : null,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Allow registration'),
                subtitle: const Text('FirebaseUiAuthOptions.registerEnabled'),
                value: _registerEnabled,
                onChanged: (value) {
                  setState(() {
                    _registerEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Allow password reset'),
                subtitle: const Text(
                  'FirebaseUiAuthOptions.lostPasswordEnabled',
                ),
                value: _lostPasswordEnabled,
                onChanged: (value) {
                  setState(() {
                    _lostPasswordEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.lock_person_outlined),
                label: const Text('Authentication screen'),
                onPressed: () {
                  _push(
                    () => uiAuthService.authScreen(firebaseAuth: firebaseAuth),
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Login screen'),
                onPressed: signedIn
                    ? null
                    : () {
                        _push(
                          () => uiAuthService.loginScreen(
                            firebaseAuth: firebaseAuth,
                          ),
                        );
                      },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.person_outline),
                label: const Text('Profile screen'),
                onPressed: signedIn
                    ? () {
                        _push(
                          () => uiAuthService.profileScreen(
                            firebaseAuth: firebaseAuth,
                          ),
                        );
                      }
                    : null,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
                onPressed: signedIn
                    ? () {
                        firebaseAuth.signOut();
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
