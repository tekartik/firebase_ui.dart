import 'package:tekartik_app_rx_bloc/auto_dispose_state_base_bloc.dart';
import 'package:tekartik_firebase_auth/auth.dart';

/// Auth screen bloc
class AuthScreenBlocState {
  /// User
  final User? user;

  /// Auth screen bloc state
  AuthScreenBlocState({required this.user});

  /// Signed in
  bool get signedIn => user != null;
}

/// Auth screen bloc
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
}
