/// The Google Sign-In script `web/index.html` may hold back (see the
/// README): released by the first auth screen.
library;

export 'google_sign_in_script_stub.dart'
    if (dart.library.js_interop) 'google_sign_in_script_web.dart';
