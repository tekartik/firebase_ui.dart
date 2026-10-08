import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tekartik_firebase_auth_sdb/auth_sdb.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

import '../theme/example_theme.dart';
import 'demo_content_screen.dart';

/// Password of the demo accounts.
const demoPassword = 'demo1234';

/// Demo account whose email is not verified.
const demoEmail = 'camille.martin@example.com';

/// Demo account with a display name and a verified email.
const demoVerifiedEmail = 'lou.moreau@example.com';

/// Display name of [demoVerifiedEmail].
const demoVerifiedName = 'Lou Moreau';

/// In-memory auth backends showing the screens in every state at once: the
/// demo accounts exist in each of them, signed out, signed in (email not
/// verified) and signed in (verified).
class AuthGalleryDemoAccounts {
  /// Nobody signed in.
  final FirebaseAuth signedOut;

  /// [demoEmail] signed in.
  final FirebaseAuth unverified;

  /// [demoVerifiedEmail] signed in.
  final FirebaseAuth verified;

  AuthGalleryDemoAccounts._(this.signedOut, this.unverified, this.verified);

  /// Creates the backends and the accounts.
  static Future<AuthGalleryDemoAccounts> create() async {
    Future<FirebaseAuth> newAuth({String? signInEmail}) async {
      var auth = newFirebaseAuthSdbMemory() as FirebaseAuthSdb;
      await auth.createUser(
        FirebaseAuthCreateUserRequest(email: demoEmail, password: demoPassword),
      );
      await auth.createUser(
        FirebaseAuthCreateUserRequest(
          email: demoVerifiedEmail,
          password: demoPassword,
          displayName: demoVerifiedName,
          emailVerified: true,
        ),
      );
      if (signInEmail != null) {
        await auth.signInWithEmailAndPassword(
          email: signInEmail,
          password: demoPassword,
        );
      }
      return auth;
    }

    return AuthGalleryDemoAccounts._(
      await newAuth(),
      await newAuth(signInEmail: demoEmail),
      await newAuth(signInEmail: demoVerifiedEmail),
    );
  }

  /// Deletes the backends.
  Future<void> dispose() async {
    for (var auth in [signedOut, unverified, verified]) {
      await auth.app.delete();
    }
  }
}

/// A screen of the gallery.
class _GalleryEntry {
  final String title;
  final String subtitle;
  final Widget Function(AuthGalleryDemoAccounts accounts) builder;

  /// Whether the opened screen needs the theme button (no app bar actions).
  final bool themeOverlay;

  const _GalleryEntry(
    this.title,
    this.subtitle,
    this.builder, {
    this.themeOverlay = true,
  });
}

const _basic = firebaseUiAuthServiceBasic;
const _restricted = FirebaseUiAuthServiceBasic(
  options: FirebaseUiAuthOptions(
    registerEnabled: false,
    lostPasswordEnabled: false,
  ),
);

final _entries = [
  _GalleryEntry(
    'Demo content',
    'Plain material widgets, for comparison',
    (_) => const DemoContentScreen(),
    themeOverlay: false,
  ),
  _GalleryEntry(
    'Welcome',
    'authScreen, signed out',
    (accounts) => _basic.authScreen(firebaseAuth: accounts.signedOut),
  ),
  _GalleryEntry(
    'Welcome, no sign up',
    'registerEnabled: false',
    (accounts) => _restricted.authScreen(firebaseAuth: accounts.signedOut),
  ),
  _GalleryEntry(
    'Sign in',
    'loginScreen',
    (accounts) => _basic.loginScreen(firebaseAuth: accounts.signedOut),
  ),
  _GalleryEntry(
    'Sign in, no sign up nor reset',
    'registerEnabled and lostPasswordEnabled: false',
    (accounts) => _restricted.loginScreen(firebaseAuth: accounts.signedOut),
  ),
  _GalleryEntry(
    'Sign up',
    'registerScreen',
    (accounts) => _basic.registerScreen(firebaseAuth: accounts.signedOut),
  ),
  _GalleryEntry(
    'Reset password',
    'lostPasswordScreen, email pre-filled',
    (accounts) => _basic.lostPasswordScreen(
      firebaseAuth: accounts.signedOut,
      email: demoEmail,
    ),
  ),
  _GalleryEntry(
    'Signed in',
    'authScreen, email not verified',
    (accounts) => _basic.authScreen(firebaseAuth: accounts.unverified),
  ),
  _GalleryEntry(
    'Profile',
    'profileScreen, email not verified',
    (accounts) => _basic.profileScreen(firebaseAuth: accounts.unverified),
  ),
  _GalleryEntry(
    'Profile, verified',
    'profileScreen, display name and verified email',
    (accounts) => _basic.profileScreen(firebaseAuth: accounts.verified),
  ),
  _GalleryEntry(
    'Email verification',
    'emailVerificationScreen',
    (accounts) =>
        _basic.emailVerificationScreen(firebaseAuth: accounts.unverified),
  ),
];

/// All the material auth screens (`FirebaseUiAuthServiceBasic`) side by side
/// with some demo content, on in-memory demo accounts (whatever the backend
/// of the app), to compare them in every theme.
///
/// The palette button cycles through the themes in one tap. A preview opens
/// the screen, usable, with the same accounts.
class AuthGalleryScreen extends StatefulWidget {
  /// Gallery.
  const AuthGalleryScreen({super.key});

  @override
  State<AuthGalleryScreen> createState() => _AuthGalleryScreenState();
}

class _AuthGalleryScreenState extends State<AuthGalleryScreen> {
  AuthGalleryDemoAccounts? _accounts;

  /// Changes on reset, rebuilding the previews on the new accounts.
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var accounts = await AuthGalleryDemoAccounts.create();
    if (!mounted) {
      await accounts.dispose();
      return;
    }
    setState(() {
      _accounts = accounts;
      _generation++;
    });
  }

  Future<void> _reset() async {
    var previous = _accounts;
    setState(() {
      _accounts = null;
    });
    await previous?.dispose();
    await _load();
  }

  @override
  void dispose() {
    _accounts?.dispose();
    super.dispose();
  }

  void _open(_GalleryEntry entry, AuthGalleryDemoAccounts accounts) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          var screen = entry.builder(accounts);
          return entry.themeOverlay
              ? _ThemeCycleOverlay(child: screen)
              : screen;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var accounts = _accounts;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth screens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset the demo accounts',
            onPressed: accounts == null ? null : _reset,
          ),
          const ExampleThemeActions(),
        ],
      ),
      body: accounts == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                const padding = 16.0;
                const spacing = 16.0;
                var width = constraints.maxWidth - 2 * padding;
                var columns = max(1, (width + spacing) ~/ (320 + spacing));
                var cellWidth = (width - (columns - 1) * spacing) / columns;
                return CustomScrollView(
                  key: ValueKey(_generation),
                  slivers: [
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        padding,
                        padding,
                        padding,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(child: _GalleryHeader()),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(padding),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          mainAxisExtent: _PreviewCard.heightFor(cellWidth),
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          var entry = _entries[index];
                          return _PreviewCard(
                            title: entry.title,
                            subtitle: entry.subtitle,
                            onOpen: () => _open(entry, accounts),
                            child: entry.builder(accounts),
                          );
                        }, childCount: _entries.length),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

/// Current theme, theme and brightness pickers, demo accounts.
class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader();

  @override
  Widget build(BuildContext context) {
    var controller = ExampleThemeScope.of(context);
    var current = controller.choice;
    var textTheme = Theme.of(context).textTheme;
    var scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ExampleThemeSwatch(choice: current, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(current.label, style: textTheme.titleLarge)),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.palette_outlined),
              label: const Text('Next theme'),
              onPressed: controller.next,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var theme in exampleThemes)
              ChoiceChip(
                avatar: ExampleThemeSwatch(
                  choice: ExampleThemeChoice(theme, current.brightness),
                  size: 18,
                ),
                label: Text(theme.name),
                selected: theme == current.theme,
                showCheckmark: false,
                onSelected: (_) => controller.selectTheme(theme),
              ),
            SegmentedButton<Brightness>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: Brightness.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: Brightness.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: {current.brightness},
              onSelectionChanged: (selection) {
                controller.selectBrightness(selection.first);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Demo accounts (in memory, password $demoPassword): '
          '$demoEmail (email not verified), '
          '$demoVerifiedEmail (verified). '
          'Tap a screen to use it.',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// A title and a scaled down phone showing the screen.
class _PreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onOpen;
  final Widget child;

  const _PreviewCard({
    required this.title,
    required this.subtitle,
    required this.onOpen,
    required this.child,
  });

  static const _headerHeight = 64.0;
  static const _padding = 12.0;

  /// Card height for a card [width] wide.
  static double heightFor(double width) {
    var phoneWidth = width - 2 * _padding;
    return _headerHeight +
        phoneWidth * _PhonePreview.size.height / _PhonePreview.size.width +
        _padding;
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var scheme = Theme.of(context).colorScheme;
    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _headerHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              subtitle,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_full, color: scheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _padding,
                    0,
                    _padding,
                    _padding,
                  ),
                  child: _PhonePreview(child: child),
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onOpen),
            ),
          ),
        ],
      ),
    );
  }
}

/// [child] laid out on a phone sized screen, scaled down to fit, not
/// interactive.
///
/// The screen gets its own navigator, as when pushed in an app (back arrow,
/// pop on sign out).
class _PhonePreview extends StatelessWidget {
  static const size = Size(390, 780);

  final Widget child;

  const _PhonePreview({required this.child});

  @override
  Widget build(BuildContext context) {
    var scheme = Theme.of(context).colorScheme;
    var radius = BorderRadius.circular(16);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: FittedBox(
          child: SizedBox.fromSize(
            size: size,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: size,
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
                viewInsets: EdgeInsets.zero,
              ),
              child: IgnorePointer(
                child: ExcludeSemantics(
                  // A navigator can not share the hero controller of the app.
                  child: HeroControllerScope.none(
                    child: Navigator(
                      onGenerateInitialRoutes: (_, _) => [
                        MaterialPageRoute<void>(
                          builder: (_) => const Scaffold(),
                        ),
                        MaterialPageRoute<void>(builder: (_) => child),
                      ],
                      onGenerateRoute: (_) =>
                          MaterialPageRoute<void>(builder: (_) => child),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [child] with a button cycling through the themes, for the screens opened
/// from the gallery (the auth screens have no app bar actions).
class _ThemeCycleOverlay extends StatelessWidget {
  final Widget child;

  const _ThemeCycleOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    var controller = ExampleThemeScope.of(context);
    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Next theme: ${controller.nextChoice.label}',
                onPressed: controller.next,
                child: const Icon(Icons.palette_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
