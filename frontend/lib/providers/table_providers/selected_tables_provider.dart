

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/table_providers/tables_provider.dart';

import '../../models/table.dart';

final selectedTableProvider =
  NotifierProvider<SelectedTableNotifier, Set<int>>(
      () => SelectedTableNotifier(),
);

class SelectedTableNotifier extends Notifier<Set<int>>{
  @override
  Set<int> build() {
    return {};
  }

  void toggle(int tableId) {
    if (state.contains(tableId)) {
      state = {...state}..remove(tableId);
    } else {
      state = {...state, tableId};
    }
  }

  void clear() {
    state = {};
  }

  bool isOk() {
    final tables = ref.watch(tablesProvider); // List de toutes les tables
    final reservationId = ref.watch(selectedReservationIdProvider);
    final reservation = ref.watch(currentReservationProvider(reservationId));

    double totalCapacity = 0;

    for (int t in state) {
      final table = tables.value?.firstWhere((e) => e.id == t); // On va chercher les tables qui ont les id dans le state

        totalCapacity += table!.capacity;
    }

    final guests = reservation.value?.numberOfGuests;

    return totalCapacity >= guests!;
  }

}