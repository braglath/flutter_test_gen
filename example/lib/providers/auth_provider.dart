import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoggedIn;

  AuthState(this.isLoggedIn);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(false));

  void login() {
    state = AuthState(true);
  }

  void logout() {
    state = AuthState(false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
