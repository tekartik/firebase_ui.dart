# Flutter UI auth

Native `firebase_ui_auth` screens (sign in, register, forgot password,
profile, email verification) exposed through the `FirebaseUiAuthService`
interface of `tekartik_firebase_ui_auth`.

## Setup

In your `pubspec.yaml`:

```yaml
  tekartik_firebase_flutter_ui_auth:
    git:
      url: https://github.com/tekartik/firebase_ui.dart
      path: packages/firebase_flutter_ui_auth
    version: '>=0.2.0'
```

## Usage

```dart
// Once, after Firebase.initializeApp
firebaseUiAuthServiceFlutter.configureProviders(
  firebaseAuth: firebaseAuth,
  googleAuthClientId: googleAuthClientId,
);

// Registration can be disabled
const uiAuthService = FirebaseUiAuthServiceFlutter(
  options: FirebaseUiAuthOptions(registerEnabled: false),
);
uiAuthService.authScreen(firebaseAuth: firebaseAuth);
```

### Google Sign-In on the web, GDPR

The providers are configured by the first auth screen, not by
`configureProviders`: Google Sign-In only starts (and sets its `g_state`
cookie) once the user opens a sign in screen.

`google_sign_in_web` still appends Google's script
(`https://accounts.google.com/gsi/client`) at startup, before `main`. To hold
it back too until the first auth screen, add this to `web/index.html`, before
`flutter_bootstrap.js`:

```html
<script>
  // Google Sign-In script held back until the first auth screen
  // (tekartik_firebase_flutter_ui_auth releases it).
  (() => {
    const url = 'https://accounts.google.com/gsi/client';
    const held = [];
    const appendChild = Node.prototype.appendChild;
    Node.prototype.appendChild = function (node) {
      if (node instanceof HTMLScriptElement && node.src === url) {
        held.push([this, node]);
        return node;
      }
      return appendChild.call(this, node);
    };
    window.tekartikReleaseGoogleSignInScript = () => {
      Node.prototype.appendChild = appendChild;
      for (const [parent, node] of held.splice(0)) {
        appendChild.call(parent, node);
      }
    };
  })();
</script>
```

See `example/ui_auth_emulator_example` in the repository for a complete app
running on the Firebase emulators, and the `skills/` folder for agent skills
(`dart run skills@ get`).
