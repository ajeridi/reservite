import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

final numberOfGuestsProvider =
NotifierProvider<NumberOfGuestsNotifier, int>(
  NumberOfGuestsNotifier.new,
);

class NumberOfGuestsNotifier extends Notifier<int> {
  @override
  int build() {
    final selectedReservationId = ref.read(selectedReservationIdProvider);
    final currentREservation = ref.watch(currentReservationProvider(selectedReservationId));

    return currentREservation.value!.numberOfGuests;
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