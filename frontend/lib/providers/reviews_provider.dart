import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/review.dart';
import 'auth_provider.dart';

final reviewsProvider =
AsyncNotifierProvider<ReviewsNotifier, Review?>(
      () => ReviewsNotifier(),
);

class ReviewsNotifier extends AbstractAsyncNotifier<Review?> {
  @override
  FutureOr<Review?> build() async {
    // on doit regarder l'etat de connexion (si connecté en tant que client ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final selectedReservation = ref.read(selectedReservationIdProvider);
    final currentReservation = ref.read(currentReservationProvider(selectedReservation));

    final clientConnecteId = currentReservation.value?.client.id;
    final reservationId = currentReservation.value!.id;

    state = AsyncData(Review(id: 0, client: 0, restaurant: 0, reservation: 0, rating: 0, created_at: DateTime.now(), comment: ''));
    state = AsyncLoading();
    try {
      if (authNotifier.isLoggedIn){
        final isClient = await authNotifier.isClient();

        bool? hasReview = await dejaReview(clientConnecteId!, reservationId);
        print(hasReview);

        if (isClient && hasReview!) {
          print("je suis rentré dans le if");
          // si on est un client on va rechercher la review de la réservation
          return await Review.getReview(selectedReservation: selectedReservation);
        }
      }

    }catch (e){
      throw "Something went wrong!\nPlease try again later.";
    }
    return null;
  }

  Future<bool?> dejaReview(int clientConnecteId, int reservationId) async {
    try {

      bool? dejaReview = await Review.deja_review(idclient: clientConnecteId, reservationId: reservationId);
      return dejaReview;

    } catch (e){
      print(e);
      state = AsyncValue.error(
          'Something went wrong\nPlease try again later.',
          StackTrace.current
      );
    }
    return null;
  }

  @override
  Future<void> refresh() async {
    // on doit regarder l'etat de connexion (si connecté en tant que client ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final selectedReservation = ref.read(selectedReservationIdProvider);
    final currentReservation = ref.watch(currentReservationProvider(selectedReservation));

    final clientConnecteId = currentReservation.value!.client.id;
    final reservationId = currentReservation.value!.id;

    state = AsyncData(Review(id: 0, client: 0, restaurant: 0, reservation: 0, rating: 0, created_at: DateTime.now(), comment: ''));
    state = AsyncLoading();
    try {
      if (authNotifier.isLoggedIn){
        final isClient = await authNotifier.isClient();

        bool? hasReview = await dejaReview(clientConnecteId, reservationId);

        if (isClient && hasReview!) {
          // si on est un client on va rechercher la review de la réservation
          final review = await Review.getReview(selectedReservation: selectedReservation);
          AsyncData(review);
        }
      }

    }catch (e){
      throw "Something went wrong!\nPlease try again later.";
    }
    AsyncData(null);
  }

  void updateReview(Review savedReview) {
    state = AsyncLoading();
    state = AsyncData(savedReview);
  }
}