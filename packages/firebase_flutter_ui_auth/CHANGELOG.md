# 0.2.3

- With `FirebaseUiAuthOptions.deleteAccount`, the "Delete account" button of
  the profile screen runs it instead of deleting the auth user alone.
- `firebaseUiAuthRevokeAppleSignIn`: revokes the Sign in with Apple tokens
  of the signed in user before its account is deleted (App Store).

# 0.2.2

- `configureProviders(apple: true)` adds Sign in with Apple
  (`firebase_ui_oauth_apple`).

# 0.2.1

- `configureProviders` is lazy: the providers are configured by the first
  auth screen, so Google Sign-In does not start (nor set its `g_state` cookie
  on the web) before the user opens one.
- `authScreen(authContinue: ...)` passes the continue button of
  `tekartik_firebase_ui_auth` ("Sign in and join") to the shared auth screen.

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
