import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';

import '../../models/restaurant.dart';

final restaurantCapacityProvider = AsyncNotifierProvider<RestaurantCapacityNotifier, int>(() => RestaurantCapacityNotifier());

class RestaurantCapacityNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() async {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    var selectedRestaurantId = ref.watch(selectedRestaurantProvider);

    // si on est en mode edition donc selectedReservationId != 0, on prend directement l'id du restaurant depuis l'attribut reservation
    if (selectedReservationId != 0){
      final currentReservation = await ref.watch(currentReservationProvider(selectedReservationId).future);
      selectedRestaurantId = currentReservation!.restaurant!.id;
    }

    // on va chercher la capacite du restaurant
    return  await Restaurant.getRestaurantCapacity(selectedRestaurantId);
  }

}