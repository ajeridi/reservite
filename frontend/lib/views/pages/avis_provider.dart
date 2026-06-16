import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/reviews_provider.dart';
import 'package:prbd_2526_a07/providers/selectedStarProvider.dart';

import '../../models/reservation.dart';
import '../../models/review.dart';
import '../../providers/auth_provider.dart';

final avisProvider = AsyncNotifierProvider<AvisNotifier, String?>(
  AvisNotifier.new,
);

class AvisNotifier extends AsyncNotifier<String?>{
  @override
  FutureOr<String?> build() async {
    // on doit regarder l'etat de connexion (si connecté en tant que client ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final selectedReservation = ref.watch(selectedReservationIdProvider);
    final currentReservation = ref.watch(currentReservationProvider(selectedReservation));

    final clientConnecteId = currentReservation.value?.client.id;
    final reservationId = currentReservation.value!.id;

    final reviewsState = ref.watch(reviewsProvider);
    final selectedStarProviderId = ref.read(selectedStarProvider);

    try {
      if (authNotifier.isLoggedIn){
        final isClient = await authNotifier.isClient();

        bool? hasReview = await dejaReview(clientConnecteId!, reservationId);
        print(hasReview);

        if (isClient && hasReview!) {
          // si on est un client on va rechercher la review de la réservation
          return reviewsState.value!.comment;
        }
      }

    }catch (e){
      throw "Something went wrong!\nPlease try again later.";
    }
    return "";
  }

  void setSpecialRequest(String value) {
    state = AsyncData(value);
  }

  String? validate(String? value) {
    return Reservation.validateSpecialRequests(value);
  }

  void clear() {
    state = AsyncData('');
  }

  bool isValid() {
    final specialRequest = state.value!;
    return Reservation.validateSpecialRequests(specialRequest) == null;
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


}
