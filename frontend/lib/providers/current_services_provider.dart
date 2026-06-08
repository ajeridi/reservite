

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/services.dart';
import '../models/table.dart';
import 'services_provider.dart';

final currentServiceProvider = AsyncNotifierProvider.autoDispose
    .family<CurrentServiceNotifier, Services?, int>(
  // autoDispose pour detruire le provider une fois qu'on ne l'utilise plus
  CurrentServiceNotifier.new,
);

class CurrentServiceNotifier extends AbstractAsyncNotifier<Services?> {
  CurrentServiceNotifier(this.id);

  final int id;

  @override
  FutureOr<Services?> build() async {
    state = AsyncData(null);
    state = AsyncLoading();

    final selectedRestaurantId = ref.read(selectedRestaurantProvider);

    try {
      return id != 0 ? await Services.getService(id, selectedRestaurantId) : null;
    } catch (e, st) {
      throw Exception("Something went wrong.\nPlease retry later.");
    }
  }

  @override
  Future<void> refresh() async {
    state = AsyncLoading();

    final selectedRestaurantId = ref.read(selectedRestaurantProvider);
    try {
      final reservation = await Services.getService(id, selectedRestaurantId);
      state = AsyncData(reservation);
    } catch (e, st) {
      print('$e\n$st');
      throw Exception("Failed to refresh the service");
    }
  }

  // modification du service courant, puis mise a jour de la liste des services
  Future<Services> updateService({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final updated = await Services.update(
      serviceId: id,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
    state = AsyncData(updated);

    // on rafraichit la liste affichee dans la page des services
    await ref.read(servicesProvider.notifier).refresh();

    return updated;
  }
}