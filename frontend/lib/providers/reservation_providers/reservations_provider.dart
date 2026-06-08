import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/models/reservation.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';

final reservationsProvider =
    AsyncNotifierProvider<ReservationsNotifier, SplayTreeSet<Reservation>>(
        () => ReservationsNotifier(),
    );

class ReservationsNotifier extends AbstractAsyncNotifier<SplayTreeSet<Reservation>>{
  @override
  FutureOr<SplayTreeSet<Reservation>> build() async {
    // on doit regarder l'etat de connexion, car un manager n'a pas la meme liste q'un client
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    // on doit aussi regarder l'etat de selection de restaurant, car un nouveau restaurant selectionne par le manager implique un nouveau fetch des reservations
    final selectedRestaurantState = ref.watch(selectedRestaurantProvider);

    state = AsyncData(SplayTreeSet<Reservation>());
    state = AsyncLoading();
    try {
      if (authNotifier.isLoggedIn){
        final isClient = await authNotifier.isClient(); //  REMARQUE : ajouter un attribut a la classe user qui va stocker le role directement pour eviter de faire des requetes vers la DB pour verifier si le user est un client
        if (isClient) // si on est un client on va rechercher toutes les reservations du client
          return await Reservation.getReservations();
        else // si on est manager on va aller chercher les reservations du restaurant selectionne
          return await Reservation.getReservations(selectedRestaurant: selectedRestaurantState);
      }
      return SplayTreeSet();
    }catch (e){
      throw "Something went wrong!\nPlease try again later.";
    }
  }

  @override
  Future<void> refresh() async{
    await getAll();
  }

  void updateList(Reservation updatedReservation) {
    state = AsyncLoading();
    final reservations = state.value; // liste actuelle dans l'etat
    var newReservation; // va contenir la nouvelle copie de la reservation a modifier
    // on va chercher la reservation a copier
    for(var reservation in reservations!){
      if(reservation.id == updatedReservation.id){
        // copie de la reservation a modifier avec le nouveau statut
        newReservation = reservation.copyWith(status: updatedReservation.status);
      }
    }
    // suppression de la reservation obsolete
    reservations.removeWhere((res) => res.id == updatedReservation.id);
    // rajout de la nouvelle reservation mise a jour
    reservations.add(newReservation);
    // modification de la liste de l'etat
    state = AsyncData(reservations);
  }

  Future<void> getAll() async {
    state = AsyncLoading();
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final isClient = await authNotifier.isClient();

      final selectedRestaurant = ref.read(selectedRestaurantProvider);
      print('selected restaurant is $selectedRestaurant');
      final SplayTreeSet<Reservation> reservations;

      if (isClient) reservations = await Reservation.getReservations();
      else reservations = await Reservation.getReservations(selectedRestaurant: selectedRestaurant);
      state = AsyncData(reservations);
    }
    catch (e){
      print(e);
      state = AsyncValue.error(
          'Something went wrong\nPlease try again later.',
          StackTrace.current
      );
    }
  }

  void addOrUpdateReservation(Reservation savedReservation) {
    state = AsyncLoading();
    final reservations = state.value ?? SplayTreeSet();
    reservations.removeWhere((reservation) => reservation.id == savedReservation.id);
    reservations.add(savedReservation);
    state = AsyncData(reservations);
  }

  void updateListAfterEdit(Reservation updatedReservation) {
    state = AsyncLoading();
    final reservations = state.value; // liste actuelle dans l'etat
    var newReservation; // va contenir la nouvelle copie de la reservation a modifier
    // on va chercher la reservation a copier
    for(var reservation in reservations!){
      if(reservation.id == updatedReservation.id){
        // copie de la reservation a modifier avec le nouveau statut
        newReservation = reservation.copyWith(datetime: updatedReservation.datetime,
                                              numberOfGuests: updatedReservation.numberOfGuests,
                                              specialRequests: updatedReservation.specialRequests);
      }
    }
    // suppression de la reservation obsolete
    reservations.removeWhere((res) => res.id == updatedReservation.id);
    // rajout de la nouvelle reservation mise a jour
    reservations.add(newReservation);
    // modification de la liste de l'etat
    state = AsyncData(reservations);
  }

}