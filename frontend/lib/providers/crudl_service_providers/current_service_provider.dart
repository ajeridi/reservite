import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/service.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/services_per_day_provider.dart';
import 'package:prbd_2526_a07/providers/table_providers/selected_table_id_provider.dart';
import 'package:prbd_2526_a07/providers/table_providers/tables_provider.dart';

import '../../core/tools/abstract_async_notifier.dart';
import '../../models/table.dart';

final currentServiceProvider = AsyncNotifierProvider.autoDispose
    .family<CurrentServiceNotifier, Service?, int>(
  // autoDispose pour detruire le provider une fois qu'on ne l'utilise plus
  CurrentServiceNotifier.new,
);

class CurrentServiceNotifier extends AbstractAsyncNotifier<Service?> {
  CurrentServiceNotifier(this.id);

  final int id;

  @override
  FutureOr<Service?> build() async {
    state = AsyncData(null);
    state = AsyncLoading();

    final restaurantId = ref.watch(selectedRestaurantProvider);
    try {
      return id != 0 ? await Service.getService(id, restaurantId) : null;
    } catch (e, st) {
      throw Exception("Something went wrong.\nPlease retry later.");
    }
  }

  @override
  Future<void> refresh() async {
    state = AsyncLoading();
    try {
      final restaurantId = ref.watch(selectedRestaurantProvider);
      final service = await Service.getService(id, restaurantId);
      state = AsyncData(service);
    } catch (e, st) {
      print('$e\n$st');
      throw Exception("Failed to refresh the service");
    }
  }

  Future<void> saveService(int? newServiceDay, int newHeureDebut, int newHeureFin, int serviceId, int restaurantId) async {
    final serviceId = state.value == null ? 0 : state.value!.id;
    final restaurantId = ref.watch(selectedRestaurantProvider);
    final newService = await Service.save_service(newServiceDay, newHeureDebut, newHeureFin, serviceId, restaurantId);

    ref.read(servicesPerDayProvider.notifier).updateList(newService);
  }

  String getDays(int dayofweek) {
    if (dayofweek == 1) {
      return "Lundi";
    }
    if (dayofweek == 2) {
      return "Mardi";
    }
    if (dayofweek == 3) {
      return "Mercredi";
    }
    if (dayofweek == 4) {
      return "Jeudi";
    }
    if (dayofweek == 5) {
      return "Vendredi";
    }
    if (dayofweek == 6) {
      return "Samedi";
    }
    if (dayofweek == 7) {
      return "Dimanche";
    }

    return '';

  }
}