/*
* Provider qui va fournir l'etat de la reservation courante (celle selectionne ou en cours de modification)
*
* ON va utiliser un family provider, qui va prendre l'id de la reservation selectionnee (par selected_reservation_id_provider)
* puis en fonction du role du user et de l'id de la reservation, aller chercher soit dans la liste des reservations (client),
* soit directement dans la DB (manager).
*
* lien de la doc riverpod sur les family provider : https://riverpod.dev/docs/concepts2/family
* */

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';
import 'package:prbd_2526_a07/providers/reservations_provider.dart';
import 'package:prbd_2526_a07/providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/selected_tables_provider.dart';

import '../models/reservation.dart';

final currentReservationProvider = AsyncNotifierProvider.autoDispose
    .family<CurrentReservationNotifier, Reservation?, int>(
      // autoDispose pour detruire le provider une fois qu'on ne l'utilise plus
      CurrentReservationNotifier.new,
    );

class CurrentReservationNotifier extends AbstractAsyncNotifier<Reservation?> {
  CurrentReservationNotifier(this.id);

  final int id;

  @override
  FutureOr<Reservation?> build() async {
    state = AsyncData(null);
    state = AsyncLoading();
    try {
      return id != 0 ? await Reservation.getReservation(id) : null;
    } catch (e, st) {
      throw Exception("Something went wrong.\nPlease retry later.");
    }
  }

  @override
  Future<void> refresh() async {
    state = AsyncLoading();
    try {
      final reservation = await Reservation.getReservation(id);
      state = AsyncData(reservation);
    } catch (e, st) {
      print('$e\n$st');
      throw Exception("Failed to refresh the reservation");
    }
  }


  Future<void> confirmWithSelectedTables(Set<int> tableIds) async {
    if (tableIds.isEmpty) {
      throw Exception('Aucune table sélectionnée');
    }

    state = AsyncLoading();
    try {
      final confirmed = await Reservation.confirmReservation(
        reservationId: id,
        tablesId: tableIds.toList(),
      );
      state = AsyncData(confirmed);

      ref.read(selectedTableProvider.notifier).clear();
      await ref.read(reservationsProvider.notifier).refresh();
    } catch (e, st) {
      print('$e\n$st');
      state = AsyncValue.error(e, st);
    }
  }
}

// a garder pour des raisons pedagogiques
/* @override
  FutureOr<Reservation?>build() {
    final reservationsState = ref.watch(reservationsProvider).value; // si la liste se rafraichit, la reservation est rafraichie aussi (.value pour decapsuler le <AsyncValue<List<Reservations>>
    final selectedReservationIdState = ref.watch(selectedReservationIdProvider); // la reservation selectionne change si on change d'id de selection
    state = AsyncData(null);
    state = AsyncLoading();
    // on va chercher dans la liste des reservation, la reservation selectionee par son id
    for (var reservation in reservationsState!) {
      if (reservation.id == selectedReservationIdState)
        return reservation;
    }
    return null;
  }
*/
