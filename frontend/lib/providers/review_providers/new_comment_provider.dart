import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

import '../../models/review.dart';

final newCommentProvider = NotifierProvider<NewCommentNotifier, String?>(
    () => NewCommentNotifier(),
);

class NewCommentNotifier extends Notifier<String?> {
  @override
  String? build() {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    final currentReservationState = ref.watch(currentReservationProvider(selectedReservationId));

    final review = currentReservationState.value!.review;

    if (review == null) return null;
    return review.comment;
  }


  void setComment(String newComment){
    state = newComment;
  }

  String? validateComment(String newComment){
    final result = Review.validateComment(newComment);
    return result;
  }

  void clear() {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    final currentReservationState = ref.watch(currentReservationProvider(selectedReservationId));

    final review = currentReservationState.value!.review;

    if (review == null) state = null;
    else state = review.comment;
  }

}