import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/table.dart';

/*
final filteredTablesProvider =
NotifierProvider<FilteredTablesNotifier, List<Table>>(
      () => FilteredTablesNotifier(),
);

class FilteredTablesNotifier extends Notifier<List<Table>> {

  String filterStatus = 'pending';

  @override
  List<Table> build() {
    final reservations = ref.watch(reservationsProvider);
    final userRoleState = ref.watch(userRoleProvider);

    if (userRoleState.value == "manager") {
      filterStatus = 'all';
    } else {
      filterStatus = 'pending';
    }

    // on retourne uniquement quand reservations a de la data
    return reservations.when(
        data: (data) {
          return getFilteredReservations(data);
        },
        error: (err, _) => [],
        loading: () => []
    );
  }

  List<Table> getFilteredReservations(List<Table> tables) {
    List<Table> filteredReservations = [];
    for (var table in tables){
      if (filterStatus == 'all' || table.status == Table.toStatus(filterStatus)){
        filteredReservations.add(reservation);
      }
    }
    return filteredReservations;
  }

  void updateFilter(List<Reservation> reservations){
    state = getFilteredReservations(reservations);
  }
}*/
