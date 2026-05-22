import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/services/auth_service.dart';
import 'package:prbd_2526_a07/core/tools/params.dart';

// l'état qu'il gère est de type String? (le token JWT ou null si pas connecté)
final authProvider = AsyncNotifierProvider<AuthNotifier, String?>(
      () => AuthNotifier(),
);

class AuthNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final token = await AuthService.login(email, password);
      state = AsyncData(token);
    } catch (e) {
      state = AsyncError('Login failed', StackTrace.current);
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = const AsyncLoading();
    try {
      await AuthService.signup(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      await login(email, password);
    } catch (e) {
      state = AsyncError('Signup failed', StackTrace.current);
    }
  }

  void logout() {
    Params.clearValue('token');
    state = const AsyncData(null);
    print('logged out');
  }

  Future<void> resetDatabase() async {
    await AuthService.resetDatabase();
    logout();
  }

  bool get isLoggedIn => state.value != null;


  Future<bool> isClient() async {
    final result = await AuthService.isClient();

    return result;
  }

  Future<bool> isManager() async {
    final result = await AuthService.isManager();

    return result;
  }
}