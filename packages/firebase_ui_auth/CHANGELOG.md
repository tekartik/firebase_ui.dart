# 0.2.1

- `FirebaseUiAuthOptions.deleteAccount`: the app deletes the account (its
  server data too); the auth screen then shows a "Delete account" row to a
  user with an account.

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
- `AuthUiStyle`: the screens follow the page, card and field colors of the app
  theme by default (`AuthUiStyle.app`: a festenao theme shows them on its
  paper); the original tinted gradient page is `AuthUiStyle.classic`, chosen
  with `theme.withAuthUiStyle(AuthUiStyle.classic)` or
  `AuthUiStyleExtension` in `ThemeData.extensions`.
- `FirebaseUiAuthOptions.onAnonymousUserSignedIn`: an anonymous user signing
  in to an existing account (email/password or Google) hands an id token of
  the anonymous user to the app (for a server side merge); the login screen
  then says that what they did follows them.
- `authScreen(authContinue: FirebaseUiAuthContinue(label: ...))`: once
  signed in, a continue button, for a "Sign in and join" flow. The screen
  pops with a `FirebaseUiAuthContinueResult` (`continued`, the current
  `user`, `hasAccount`), going back too; `pushAuthScreenToContinue` pushes
  it and returns that result.
- `AuthAccountDetailsSection`: no email verification row for an anonymous
  user.

# 0.1.0

- Initial version
