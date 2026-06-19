import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/models/service.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';

final currentServiceProvider = AsyncNotifierProvider.autoDispose.family<CurrentServiceNotifier, Service?, int>(
  CurrentServiceNotifier.new,
);

class CurrentServiceNotifier extends AbstractAsyncNotifier<Service?> {
  CurrentServiceNotifier(this.id);
  final int id;

  @override
  Future<Service?> build() async {
    try {
      if (id == 0){
        return null;
      }
      final reservationId = ref.read(selectedRestaurantProvider);
      final service = await Service.getService(id, reservationId);
      return service;
    } catch(e, st) {
      AsyncError("Erreur ", st);
      throw Exception(e);
    }
  }

  @override
  Future<void> refresh() {
    // TODO: implement refresh
    throw UnimplementedError();
  }

}