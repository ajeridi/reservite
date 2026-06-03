import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/available_slots.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_date_provider.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';

typedef Parameters = ({
  int restaurantId,
  DateTime selectedDate,
}); // type custom pour les parametre : https://stackoverflow.com/questions/69620756/flutter-riverpod-how-to-pass-multiple-arguments-in-family

final availableSlotsProvider =
    AsyncNotifierProvider<AvailableSlotsNotifier, AvailableSlots>(
      () => AvailableSlotsNotifier(),
    );

class AvailableSlotsNotifier extends AsyncNotifier<AvailableSlots> {
  @override
  FutureOr<AvailableSlots> build() async {
    final selectedReservationDate = await ref.watch(selectedReservationDateProvider.future);
    final selectedRestaurantId = ref.watch(selectedRestaurantProvider);
    try {
      return await AvailableSlots.getAvailableSlots(selectedRestaurantId, selectedReservationDate);
    } catch (e, st) {
      debugPrint('$e\n$st');
      throw Exception('Failed to build available slots notifier');
    }
  }
}
