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

    final selectedReservationId = ref.read(selectedReservationIdProvider);
    final currentRestaurant = ref.watch(currentReservationProvider(selectedReservationId)).value!.restaurant!.id;

    final selectedReservationDate =
    await ref.watch(selectedReservationDateProvider.future);

    if (selectedSlot == null) { // si pas de slot, pas de check donc retourner true
      return true;
    }

    return Reservation.checkCapacity(
      restaurantId: currentRestaurant,
      date: selectedReservationDate,
      slot: selectedSlot,
      numberOfGuests: numberOfGuests,
    );
  }
}