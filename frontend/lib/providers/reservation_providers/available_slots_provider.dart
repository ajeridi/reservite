import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/models/available_slots.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_date_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_slot_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';

final availableSlotsProvider =
    AsyncNotifierProvider.autoDispose<AvailableSlotsNotifier, AvailableSlots>(
      () => AvailableSlotsNotifier(),
    );

class AvailableSlotsNotifier extends AsyncNotifier<AvailableSlots> {
  @override
  FutureOr<AvailableSlots> build() async {
    final selectedReservationDate = await ref.watch(selectedReservationDateProvider.future);

    var selectedRestaurantId = ref.watch(selectedRestaurantProvider);
    final selectedReservationId = ref.watch(selectedReservationIdProvider);


    try {

      // si restaurant Id vaut 0, on est sur une modification de reservation (donc faut donner l'id du restaurant de la reservation modifiee
      // fix : ne pas prendre en compte le selectedRestaurant, car il ne s'actualise pas correctement lorsqu'on change de reservations dans le cas d'edit
      if (selectedReservationId != 0) // si en mode edit
        selectedRestaurantId = ref.watch(currentReservationProvider(selectedReservationId)).value!.restaurant!.id;

      final availableSlots = await AvailableSlots.getAvailableSlots(
        selectedRestaurantId,
        selectedReservationDate,
        selectedReservationId,
      );

      final slots = availableSlots.slots ?? [];

      if (slots.isEmpty) { // si pas de slots, on nettoie le selectedSlotProvider
        ref.read(selectedSlotProvider.notifier).clear();
      } else {
        //on selectionne le premier creneau disponible dans le cas d'une nouvelle reservation
        if (selectedReservationId == 0)
          ref.read(selectedSlotProvider.notifier).setSelectedSlot(slots.first);
        else { // on selectionne le slot qui est celui de la reservation existante
          await selectSlot(selectedReservationId, slots);
        }
      }
      return availableSlots;
    } catch (e, st) {
      debugPrint('$e\n$st');
      throw Exception('Failed to build available slots notifier');
    }
  }

  Future<void> selectSlot(int selectedReservationId, List<String> slots) async {
     final currentReservation = await ref.watch(currentReservationProvider(selectedReservationId).future);
    final reservationDateTime = currentReservation!.datetime;
    final reservationSlot =  DateFormat('HH:mm:ss', 'fr_FR',).format(reservationDateTime);
    final selectedSlotNotifier = ref.read(selectedSlotProvider.notifier);
    // si le creneau existe dans la liste des creneau
    if (slots.contains(reservationSlot))
      selectedSlotNotifier.setSelectedSlot(reservationSlot);
    else // sinon on dit qu'il est null
      selectedSlotNotifier.setSelectedSlot(null);
  }
}
