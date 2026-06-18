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
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';
import 'package:prbd_2526_a07/providers/client_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/reservations_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_date_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_slot_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/special_request_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';

import '../../models/reservation.dart';
import '../table_providers/selected_tables_provider.dart';
import 'capacity_check_provider.dart';
import 'number_of_guests_provider.dart';


final currentReservationProvider = AsyncNotifierProvider
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
      // si id != 0, on a clique sur une reservation, on va donc la chercher avec son id
      if (id != 0) return await Reservation.getReservation(id);
      else { // si l'id vaut 0, on retourne une reservation vide
        return null;
      }
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
  // on appelle getCancel sûr la state, ensuite on update la page de reservations grâce a updateList
  Future<void> cancel()  async{
    final canceled = await state.value!.getCancel();
    state = AsyncData(canceled);
    ref.read(reservationsProvider.notifier).updateList(state.value!);
  }


  Future<Reservation> saveReservation({required DateTime selectedDate, required String selectedSlot, required int numberOfGuests, required bool capacityCheck, String? specialRequest,}) async {
    // recherche de toutes les donnes entree par l'utilisateur via les providers
    int restaurantId = ref.read(selectedRestaurantProvider);
    final reservationId = ref.read(selectedReservationIdProvider);

    if (reservationId != 0){ // si on modifie une reservation, il faut chercher l'id du restaurant (sinon il vaut 0)
      restaurantId = state.value!.restaurant!.id;
    }

    // dernieres validations
    if (selectedSlot == null) {
      throw Exception('Veuillez sélectionner un créneau.');
    }

    final savedReservation = await Reservation.saveReservation(
      restaurantId: restaurantId,
      date: selectedDate,
      slot: selectedSlot,
      numberOfGuests: numberOfGuests,
      specialRequests: specialRequest!.isEmpty ? null : specialRequest,
      reservationId: reservationId == 0 ? null : reservationId,
    );

    state = AsyncData(savedReservation);

    // mettre a jour directement la liste soit en ajoutant si nouvelle reseravation, soit en supprimant et en rajoutant la nouvelle
    ref.read(reservationsProvider.notifier).addOrUpdateReservation(savedReservation);

    return savedReservation;
  }

// on appelle getCompleted sûr la state, ensuite on update la page de reservations grâce a updateList
Future<void> complete() async{
    final completed = await state.value!.getCompleted();
    state = AsyncData(completed);
    ref.read(reservationsProvider.notifier).updateList(state.value!);
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




