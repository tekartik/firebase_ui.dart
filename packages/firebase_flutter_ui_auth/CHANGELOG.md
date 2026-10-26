# 0.2.1

- `configureProviders` is lazy: the providers are configured by the first
  auth screen, so Google Sign-In does not start (nor set its `g_state` cookie
  on the web) before the user opens one. On the web, a `web/index.html`
  snippet (README) also holds Google's script back until then.

# 0.2.0

- `FirebaseUiAuthServiceFlutter` gets `options` (`registerEnabled` toggles the
  native sign-in/register switch), `registerScreen` and `lostPasswordScreen`
  (native `RegisterScreen` and `ForgotPasswordScreen`).
- Fix `emailVerificationScreen` which was returning the profile screen.
- `registerScreen` gets an app bar with a back button (the native
  `RegisterScreen` has none and the sign-in switch is hidden, so there was
  no way to leave the screen).

# 0.1.0

- Initial version
