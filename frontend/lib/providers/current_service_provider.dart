import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/models/service.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';
final currentServiceProvider = AsyncNotifierProvider.autoDispose.family<CurrentServiceNotifier, Service?,int>(
  CurrentServiceNotifier.new,
);

class CurrentServiceNotifier extends AbstractAsyncNotifier<Service?> {
  CurrentServiceNotifier(this.id);

  final int id;

  @override
  FutureOr<Service?> build() async {
    state = AsyncData(null);
    state = AsyncLoading();
    try {
      final restaurantId = ref.watch(selectedRestaurantProvider);
      return id != 0 ? await Service.getService(id, restaurantId) : null;
    } catch (e, st) {
      throw Exception("Something went wrong.\nPlease retry later.");
    }
  }

  @override
  Future<void> refresh() async {
    // TODO: implement refresh
    state = AsyncLoading();
    try {
      final restaurantId = ref.watch(selectedRestaurantProvider);
      final reservation = await Service.getService(id, restaurantId);
      state = AsyncData(reservation);
    } catch (e, st) {
      print('$e\n$st');
      throw Exception("Failed to refresh the service");
    }
  }



}