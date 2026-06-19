import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

final numberOfGuestsProvider =
NotifierProvider.autoDispose<NumberOfGuestsNotifier, int>(
  NumberOfGuestsNotifier.new,
);

class NumberOfGuestsNotifier extends Notifier<int> {
  @override
  int build() {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    // si c'est une nouvelle reservation on retourne 2
    if (selectedReservationId == 0)
      return 2;
    // si c'est une reservation existante on retourne le number of guest de la reservation
    final currentReservation = ref.watch(currentReservationProvider(selectedReservationId)).asData;
    return currentReservation!.value!.numberOfGuests;
  }

  void increment() {
    state++;
  }

  void decrement() {
    if (state > 1) {
      state--;
    }
  }

  void setNumberOfGuests(int value) {
    if (value >= 1) {
      state = value;
    }
  }
}