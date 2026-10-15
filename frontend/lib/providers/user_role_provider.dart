/*
* Provider qui va retourner le role de l'utilisateur connecte
* Il va watch authProvider, puis des que auth provider change il va retourner le role de l'utilisateur connecte
* null si utilisateur non connecte
* */
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';

final userRoleProvider = AsyncNotifierProvider<UserRoleNotifier, String?>(
  () => UserRoleNotifier(),
);

class UserRoleNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() async {
    state = AsyncData(null);
    state = AsyncLoading();
    // on observe l'etat de connection
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    try {
      if (!authNotifier.isLoggedIn) return null;
      return await authNotifier.getRole();
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }
}