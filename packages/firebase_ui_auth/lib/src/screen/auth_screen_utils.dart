import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_widget/view/busy_screen_state_mixin.dart';
import 'package:tekartik_app_rx_bloc_flutter/app_rx_flutter.dart';
import 'package:tekartik_firebase_ui_auth/ui_auth.dart';

/// Pops the screen of [state] with [result] (the user by default) the first
/// time the auth state matches [when]; [beforePop] runs just before.
void authScreenPopWhen(
  State state, {
  required bool Function(AuthScreenBlocState authState) when,
  Object? Function(AuthScreenBlocState authState)? result,
  VoidCallback? beforePop,
}) {
  scheduleMicrotask(() async {
    if (!state.mounted) {
      return;
    }
    var bloc = BlocProvider.of<AuthScreenBloc>(state.context);
    await for (var authState in bloc.state) {
      if (when(authState)) {
        if (state.mounted) {
          beforePop?.call();
          Navigator.of(state.context)
              .pop(result == null ? authState.user : result(authState));
        }
        return;
      }
    }
  });
}

/// Whether [error] says the email belongs to another account: the codes of
/// the native (`email-already-in-use`), local (`email-already-exists`) and
/// rest (`EMAIL_EXISTS`) backends.
bool authIsEmailInUseError(Object error) {
  var text = error.toString();
  return text.contains('email-already-in-use') ||
      text.contains('email-already-exists') ||
      text.contains('EMAIL_EXISTS');
}

/// Submit helper of the form screens (login, register, lost password).
extension AuthScreenSubmitExt<T extends StatefulWidget> on BusyScreenState<T> {
  /// Runs [action] while busy when [check] allows it, shows [errorMessage]
  /// in [error] when it fails, or the message [errorMessageOf] gives for that
  /// error when not null.
  ///
  /// [check] (which reads busy) runs again once no longer busy: the submit
  /// button is enabled again after a failure without editing a field.
  Future<void> authSubmit({
    required bool Function() check,
    required BehaviorSubject<String?> error,
    required String errorMessage,
    String? Function(Object error)? errorMessageOf,
    required Future<void> Function() action,
  }) async {
    if (!check()) {
      return;
    }
    await busyAction(() async {
      try {
        error.add(null);
        await action();
      } catch (e, st) {
        if (kDebugMode) {
          print('Error $e');
          print(st);
        }
        error.add(errorMessageOf?.call(e) ?? errorMessage);
      }
    });
    if (mounted) {
      check();
    }
  }
}
