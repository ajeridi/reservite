import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/available_slots.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_date_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_slot_provider.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';

final availableSlotsProvider =
    AsyncNotifierProvider<AvailableSlotsNotifier, AvailableSlots>(
      () => AvailableSlotsNotifier(),
    );

class AvailableSlotsNotifier extends AsyncNotifier<AvailableSlots> {
  @override
  FutureOr<AvailableSlots> build() async {
    final selectedReservationDate =
    await ref.watch(selectedReservationDateProvider.future);

    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    final idRestaurantFromReservation = ref.watch(currentReservationProvider(selectedReservationId)).value?.restaurant?.id;

    try {
      final availableSlots = await AvailableSlots.getAvailableSlots(
        idRestaurantFromReservation!,
        selectedReservationDate,
        selectedReservationId
      );

      final slots = availableSlots.slots ?? [];

      if (slots.isEmpty) { // si pas de slots, on nettoie le selectedSlotProvider
        ref.read(selectedSlotProvider.notifier).clear();
      } else { // sinon on selectionne le premier creneau disponible
        ref.read(selectedSlotProvider.notifier).setSelectedSlot(slots.first);
      }
      return availableSlots;
    } catch (e, st) {
      debugPrint('$e\n$st');
      throw Exception('Failed to build available slots notifier');
    }
  }
}
