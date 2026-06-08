import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_date_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_slot_provider.dart';

import '../../models/reservation.dart';
import '../selected_restaurant_provider.dart';
import 'number_of_guests_provider.dart';

final capacityCheckProvider =
AsyncNotifierProvider<CapacityCheckNotifier, bool>(
  () => CapacityCheckNotifier(),
);

class CapacityCheckNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final numberOfGuests = ref.watch(numberOfGuestsProvider);
    final selectedSlot = ref.watch(selectedSlotProvider);
    var selectedRestaurantId = ref.watch(selectedRestaurantProvider);

    final selectedReservationDate =
    await ref.watch(selectedReservationDateProvider.future);

    final selectedReservationId = ref.watch(selectedReservationIdProvider);

    if (selectedReservationId != 0) { // si en mode edition il faut prendre le restaurant de la reservation selectionnee (ne pas se baser sur selectedRestaurant = 0)
      final currentReservation = await ref.watch(currentReservationProvider(selectedReservationId).future);
      selectedRestaurantId = currentReservation!.restaurant!.id;
    }

    if (selectedSlot == null) { // si pas de slot, pas de check donc retourner true
      return true;
    }

    return Reservation.checkCapacity(
      restaurantId: selectedRestaurantId,
      date: selectedReservationDate,
      slot: selectedSlot,
      numberOfGuests: numberOfGuests,
      reservation_id: selectedReservationId
    );
  }
}