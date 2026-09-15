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
