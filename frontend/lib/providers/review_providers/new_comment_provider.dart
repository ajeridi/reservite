import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/review.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

final newCommenrProvider = NotifierProvider.autoDispose<NewCommentNotifier,String>(
    () => NewCommentNotifier(),
);

class NewCommentNotifier extends Notifier<String> {

  @override
  String build() {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    final currentReservationState = ref.watch(currentReservationProvider(selectedReservationId));

    final review = currentReservationState.value!.review;

    if(review == null) return '';

    return state = review.comment!;
  }

  void setComment(String newComment){
    state = newComment;
  }

  String? validateComm(String newComm){
    Review.validateComment(newComm);
  }
}