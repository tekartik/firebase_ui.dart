/// Configuration of the local Firebase emulators used by the example.
///
/// Pure Dart (no Flutter import) so that the `tool/` scripts can use it.
library;

/// Placeholder project id.
///
/// The `demo-` prefix tells the Firebase CLI and SDKs that the project does not
/// exist: everything runs locally in the emulators, no credentials needed.
const emulatorProjectId = 'demo-placeholder-ui-auth';

/// Placeholder api key (any non empty value works with the emulators).
const emulatorApiKey = 'placeholder-api-key';

/// Host of the emulators (the Android emulator maps it to 10.0.2.2).
const emulatorHost = 'localhost';

/// Auth emulator port (see emulator/firebase.json).
const authEmulatorPort = 9099;

/// Firestore emulator port (see emulator/firebase.json).
const firestoreEmulatorPort = 8080;

/// Emulator UI port (see emulator/firebase.json).
const emulatorUiPort = 4000;

/// Hardcoded test user, created on first sign-in. The firestore rules give it
/// write access to the `admin_items` collection.
const testUserEmail = 'test.user@example.com';

/// Password of the hardcoded test user.
const testUserPassword = 'test1234';

/// Public items collection (readable by everyone).
const publicItemsCollection = 'public_items';

/// Admin items collection (writable by the test user only).
const adminItemsCollection = 'admin_items';

/// Private items collection of a user.
String userItemsCollection(String userId) => 'users/$userId/items';

/// Id of the document used by the rules test.
const rulesTestDocId = 'rules_test';
