import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

import 'emulator_config.dart';
import 'firebase_context.dart';
import 'screen/items_screen.dart';
import 'screen/rules_test_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var context = await initExampleFirebaseContext();
  runApp(ExampleApp(firebaseContext: context));
}

/// Example app.
class ExampleApp extends StatelessWidget {
  /// Firebase context (native, rest or local).
  final ExampleFirebaseContext firebaseContext;

  /// Example app.
  const ExampleApp({super.key, required this.firebaseContext});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF5B4FE9);
    return MaterialApp(
      title: 'UI auth emulator example',
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
        FirebaseUILocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales:
          FirebaseUiAuthServiceBasicLocalizations.supportedLocales,
      home: HomeScreen(firebaseContext: firebaseContext),
    );
  }
}

/// Home screen: backend info, current user and entry points.
class HomeScreen extends StatefulWidget {
  /// Firebase context.
  final ExampleFirebaseContext firebaseContext;

  /// Home screen.
  const HomeScreen({super.key, required this.firebaseContext});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ExampleFirebaseContext get firebaseContext => widget.firebaseContext;

  FirebaseAuth get auth => firebaseContext.auth;

  FirebaseUiAuthService get uiAuthService => firebaseContext.uiAuthService;

  var _busy = false;

  void _push(Widget Function() builder) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => builder()));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('UI auth emulator example')),
      body: StreamBuilder<User?>(
        stream: auth.onCurrentUser,
        builder: (context, snapshot) {
          var user = snapshot.data;
          var signedIn = user != null;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Backend', style: textTheme.labelLarge),
                      Text(
                        '${firebaseContext.backendName} '
                        '(${uiAuthService.runtimeType})',
                      ),
                      const SizedBox(height: 8),
                      Text('Project', style: textTheme.labelLarge),
                      const Text(emulatorProjectId),
                      const SizedBox(height: 8),
                      Text('Emulators', style: textTheme.labelLarge),
                      const Text(
                        'auth $emulatorHost:$authEmulatorPort, '
                        'firestore $emulatorHost:$firestoreEmulatorPort, '
                        'UI http://$emulatorHost:$emulatorUiPort',
                      ),
                      if (!firebaseContext.rulesEnforced) ...[
                        const SizedBox(height: 8),
                        const Text('Local backend: rules are not enforced'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
              FilledButton.icon(
                icon: const Icon(Icons.science_outlined),
                label: const Text('Sign in as test user'),
                onPressed: signedIn || _busy
                    ? null
                    : () {
                        _run(firebaseContext.signInAsTestUser);
                      },
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.lock_person_outlined),
                label: const Text('Authentication screen'),
                onPressed: () {
                  _push(() => uiAuthService.authScreen(firebaseAuth: auth));
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
                          () => uiAuthService.loginScreen(firebaseAuth: auth),
                        );
                      },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.list_alt_outlined),
                label: const Text('Public items (FirestoreListView)'),
                onPressed: () {
                  _push(() => ItemsScreen(firebaseContext: firebaseContext));
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.rule),
                label: const Text('Rules test'),
                onPressed: () {
                  _push(
                    () => RulesTestScreen(firebaseContext: firebaseContext),
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
                onPressed: signedIn && !_busy
                    ? () {
                        _run(() => auth.signOut());
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                'Test user: $testUserEmail / $testUserPassword',
                style: textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
