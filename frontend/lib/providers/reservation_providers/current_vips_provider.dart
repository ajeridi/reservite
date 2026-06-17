

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';
import 'package:prbd_2526_a07/providers/client_provider.dart';
import 'package:prbd_2526_a07/providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/reservations_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_date_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_slot_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/special_request_provider.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';

import '../../models/reservation.dart';
import '../selected_tables_provider.dart';
import 'capacity_check_provider.dart';
import 'number_of_guests_provider.dart';


final currentVipsProvider = AsyncNotifierProvider
    .family<CurrentVipsNotifier, int?, int>(
  // autoDispose pour detruire le provider une fois qu'on ne l'utilise plus
  CurrentVipsNotifier.new,
);

class CurrentVipsNotifier extends AsyncNotifier<int?> {
  CurrentVipsNotifier(this.id);

  final int id;

  @override
  FutureOr<int?> build() async {
    state = AsyncData(0);
    state = AsyncLoading();

    final selectedRestaurantId = ref.read(selectedRestaurantProvider);
    final currentRestaurantId = ref.watch(currentRestaurantProvider(selectedRestaurantId));
    final restaurantId = currentRestaurantId.value!.id;

    final selectedReservation = ref.read(selectedReservationIdProvider);

    try {
       return await Reservation.get_vip_reservation_count(restaurantId: restaurantId);
    } catch (e, st) {
      print('$e\n$st');
      state = AsyncValue.error(e, st);
      throw Exception("Something went wrong.\nPlease retry later.");
    }
  }

  Future<int> get_vip_reservation_count(int restaurantId) async {
    int restaurantId = ref.read(selectedRestaurantProvider);
    state = AsyncLoading();
    try {
      final getVipCount = await Reservation.get_vip_reservation_count(
          restaurantId: restaurantId
      );
      state = AsyncData(getVipCount);
      return getVipCount;
    } catch (e, st) {
      print('$e\n$st');
      state = AsyncValue.error(e, st);
      throw Exception("Something went wrong.\nPlease retry later.");
    }
  }

}