import 'dart:async';

import 'package:tekartik_app_rx_bloc/state_base_bloc.dart';
import 'package:tekartik_firebase_auth/auth.dart';

class AuthScreenBlocState {
  final User? user;

  AuthScreenBlocState({required this.user});

  bool get signedIn => user != null;
}

class AuthScreenBloc extends StateBaseBloc<AuthScreenBlocState> {
  late final FirebaseAuth firebaseAuth;
  late StreamSubscription subscription;
  AuthScreenBloc({FirebaseAuth? firebaseAuth}) {
    this.firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
    subscription = this.firebaseAuth.onCurrentUser.listen((user) {
      add(AuthScreenBlocState(user: user));
    });
  }
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
