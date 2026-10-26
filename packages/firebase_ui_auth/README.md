# UI auth

Email/password authentication screens for Flutter built on the
`tekartik_firebase_auth` abstraction: sign in, sign up (optional), lost
password, profile and email verification. Works with any backend (native
Flutter, REST, local sdb/sembast). English and French included.

## Setup

In your `pubspec.yaml`:

```yaml
  tekartik_firebase_ui_auth:
    git:
      url: https://github.com/tekartik/firebase_ui.dart
      path: packages/firebase_ui_auth
    version: '>=0.2.0'
```

Add the localization delegate to your `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: const [
    FirebaseUiAuthServiceBasicLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: FirebaseUiAuthServiceBasicLocalizations.supportedLocales,
  ...
)
```

## Usage

```dart
// Default service (registration and lost password enabled)
var uiAuthService = firebaseUiAuthServiceBasic;

// Or customize the features
const uiAuthService = FirebaseUiAuthServiceBasic(
  options: FirebaseUiAuthOptions(registerEnabled: false),
);

// An anonymous user creating an account keeps its uid (linked) by default,
// a new user instead:
const newUserUiAuthService = FirebaseUiAuthServiceBasic(
  options: FirebaseUiAuthOptions(linkAnonymousUser: false),
);

Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => uiAuthService.authScreen(firebaseAuth: firebaseAuth),
  ),
);
```

Screens: `authScreen`, `loginScreen`, `registerScreen`, `lostPasswordScreen`,
`profileScreen`, `emailVerificationScreen`.

### Sign in to do something ("Sign in and join")

Once signed in, the auth screen is a dead end: its only way out is back. Pass
`authContinue` to add a button that goes on; the screen then tells the caller
how it closed, a `FirebaseUiAuthContinueResult`:

```dart
var result = await uiAuthService.pushAuthScreenToContinue(
  context,
  firebaseAuth: firebaseAuth,
  authContinue: const FirebaseUiAuthContinue(label: 'Join'),
);
if (result.continued) {
  // They tapped "Join" (signed in to an account): join for them.
  await join(result.user!);
} else if (result.hasAccount) {
  // Back, signed in: the page rebuilds from the auth state and offers
  // "Join" instead of "Sign in and join".
}
```

| Closed by | `continued` | `user` / `hasAccount` |
|---|---|---|
| The continue button | `true` | the signed-in user / `true` |
| Back, signed in | `false` | the signed-in user / `true` |
| Back, signed out | `false` | `null` / `false` |

`uiAuthService.authScreen(authContinue: ...)` builds the same screen for an
app pushing its own routes (go_router): read the result of
`context.push<FirebaseUiAuthContinueResult>(...)`. The screen catches back
(app bar, system back) to pop with its result, so the iOS swipe back is off
on it. The label defaults to "Continue" (localized). `loginScreen` needs none
of this: it pops with the `User` as soon as the user signs in.

The design follows the app `ColorScheme` (use
`ThemeData(colorSchemeSeed: Color(0xFF5B4FE9))` for the reference look).

See `example/ui_auth_sdb_example` in the repository for a complete offline
example using `tekartik_firebase_auth_sdb`, and the `skills/` folder for
agent skills (`dart run skills@ get`).
