import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/reservation.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/reservations_provider.dart';
import 'package:prbd_2526_a07/providers/user_role_provider.dart';

import '../auth_provider.dart';

/*
* But de ce provider :
*   Il va regarder l'etat de la liste de reservation existante fournie par le reservationsProvider
*   puis en fonction du status selectionne, va cree une liste filtree en fonction de la liste courante de reservations
* */

final filteredReservationsProvider =
    NotifierProvider<FilteredReservationsNotifier, SplayTreeSet<Reservation>>(
        () => FilteredReservationsNotifier(),
    );

class FilteredReservationsNotifier extends Notifier<SplayTreeSet<Reservation>> {

  String filterStatus = 'pending';

  @override
  SplayTreeSet<Reservation> build() {
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
        error: (err, _) => SplayTreeSet<Reservation>(),
        loading: () => SplayTreeSet<Reservation>()
    );
  }

  SplayTreeSet<Reservation> getFilteredReservations(SplayTreeSet<Reservation> reservations) {
    SplayTreeSet<Reservation> filteredReservations = SplayTreeSet();
    for (var reservation in reservations){
      if (filterStatus == 'all' || reservation.status == Reservation.toStatus(filterStatus)){
        filteredReservations.add(reservation);
      }
    }
    return filteredReservations;
  }

  void updateFilter(SplayTreeSet<Reservation> reservations){
    state = getFilteredReservations(reservations);
  }
}