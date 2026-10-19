import 'package:tekartik_app_rx_bloc/auto_dispose_state_base_bloc.dart';
import 'package:tekartik_firebase_auth/auth.dart';

/// Auth screen bloc state
class AuthScreenBlocState {
  /// User
  final User? user;

  /// Auth screen bloc state
  AuthScreenBlocState({required this.user});

  /// Signed in
  bool get signedIn => user != null;

  /// Signed in with an account: anonymous users have none, the auth screens
  /// offer them to sign in or create one.
  bool get hasAccount => !(user?.isAnonymous ?? true);

  @override
  String toString() => 'AuthScreenBlocState(${user?.uid})';
}

/// Auth screen bloc, shared by all the auth screens.
///
/// It exposes the current user as a state and wraps the [FirebaseAuth]
/// operations used by the screens.
class AuthScreenBloc extends AutoDisposeStateBaseBloc<AuthScreenBlocState> {
  /// firebase auth
  late final FirebaseAuth firebaseAuth;

  /// Auth screen bloc
  AuthScreenBloc({FirebaseAuth? firebaseAuth}) {
    this.firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
    audiAddStreamSubscription(
      this.firebaseAuth.onCurrentUser.listen((user) {
        add(AuthScreenBlocState(user: user));
      }),
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

  /// Create a user (register) with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) => firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  /// Whether the current user is anonymous.
  bool get isAnonymous => firebaseAuth.currentUser?.isAnonymous ?? false;

  /// Link an email and password to the current (anonymous) user, which keeps
  /// its uid, see [FirebaseUser.linkWithCredential].
  Future<UserCredential> linkWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    var user = firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('No current user to link');
    }
    return user.linkWithCredential(
      FirebaseAuthEmailPasswordCredential(email: email, password: password),
    );
  }

  /// Send a password reset email
  Future<void> sendPasswordResetEmail({required String email}) =>
      firebaseAuth.sendPasswordResetEmail(email: email);

  /// Send a verification email to the current user
  Future<void> sendEmailVerification() => firebaseAuth.sendEmailVerification();

  /// Reload the current user (for example to refresh its verified status)
  Future<User?> reloadCurrentUser() => firebaseAuth.reloadCurrentUser();
}
