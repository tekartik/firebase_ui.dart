import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// The function `web/index.html` defines to append the script it held back
/// (see the README).
const _release = 'tekartikReleaseGoogleSignInScript';

/// Appends the Google Sign-In script held back by `web/index.html`, nothing
/// to do without the snippet (the script loaded at startup).
void releaseGoogleSignInScript() {
  if (globalContext.has(_release)) {
    globalContext.callMethod(_release.toJS);
  }
}
