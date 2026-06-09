import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

final newRatingProvider = NotifierProvider.autoDispose<NewRatingNotifier, int>(
() => NewRatingNotifier(),
);

class NewRatingNotifier extends Notifier<int> {


  @override
  int build() {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    final currentReservationState = ref.watch(currentReservationProvider(selectedReservationId));

    final review = currentReservationState.value!.review;

    if(review == null) return 2;

    return state =review.rating;
  }

  void setRating(int newRating){
    state = newRating;
  }
}