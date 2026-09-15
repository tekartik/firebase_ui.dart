# 0.2.0

- New design for all screens (auth, login, profile) inspired by a card based
  "account access" layout, adapting to the app color scheme (light and dark).
- Add `AuthRegisterScreen` (sign up) and `FirebaseUiAuthOptions.registerEnabled`
  to make registration optional.
- Add `AuthLostPasswordScreen` (password reset email) and
  `FirebaseUiAuthOptions.lostPasswordEnabled`.
- Add a basic `AuthEmailVerificationScreen`.
- `FirebaseUiAuthService` gets `options`, `registerScreen` and
  `lostPasswordScreen`.
- Complete English and French localization of every string.
- Export `AuthUserHeaderCard`, `AuthAccountDetailsSection` and `AuthUiTheme`.

# 0.1.0

- Initial version
