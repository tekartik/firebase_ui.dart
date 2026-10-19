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
- Button and link labels derive from the theme `labelLarge` style
  (`AuthUiTheme.buttonTextStyle`, `linkTextStyle`), so the app font family
  applies to them too.
- Export `AuthUserHeaderCard`, `AuthAccountDetailsSection` and `AuthUiTheme`.
- `FirebaseUiAuthOptions.linkAnonymousUser` (default `true`): for an anonymous
  user the register screen links the new account to it
  (`FirebaseUser.linkWithCredential`, same uid), and the login screen says
  that signing in switches account. An email in use gets its own message.
- `FirebaseUiAuthOptions.onAnonymousUserSignedIn`: an anonymous user signing
  in to an existing account (email/password or Google) hands an id token of
  the anonymous user to the app (for a server side merge); the login screen
  then says that what they did follows them.

# 0.1.0

- Initial version
