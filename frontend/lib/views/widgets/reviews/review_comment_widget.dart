import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/validating_text_editing_controller.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/review_providers/new_comment_provider.dart';

class ReviewCommentWidget extends ConsumerStatefulWidget {
  const ReviewCommentWidget({
    super.key,
  });

  @override
  _ReviewCommentWidgetState createState() => _ReviewCommentWidgetState();

}

  class _ReviewCommentWidgetState extends ConsumerState<ReviewCommentWidget>{
  late ValidatingTextEditingController _commentController = ValidatingTextEditingController(

  );

  @override
  void initState() {
    super.initState();

    final newCommentState = ref.read(newCommenrProvider);
    final newCommentNotifier = ref.read(newCommenrProvider.notifier);
    _commentController = new ValidatingTextEditingController(
        initialValue: newCommentState,
    validator: (s) => newCommentNotifier.validateComm(s)
    );
    _commentController.onAfterValidated = () => setState(() {

    });
  }


  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);
    final  currentReservationState = ref.watch(currentReservationProvider(selectedReservationId));
    return TextField(
      maxLines: 3,
      decoration: InputDecoration(
          labelText: 'Commentaire (optionnel)',
          border: const OutlineInputBorder(),
          hintText: 'Votre commentaire ...'
      ),
    );
  }
}