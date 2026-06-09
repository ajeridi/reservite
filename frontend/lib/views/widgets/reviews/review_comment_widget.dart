import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/validating_text_editing_controller.dart';

import '../../../providers/review_providers/new_comment_provider.dart';

class ReviewCommentWidget extends ConsumerStatefulWidget {
  const ReviewCommentWidget({
    super.key,
  });

  @override
  _ReviewCommentWidgetState createState() => _ReviewCommentWidgetState();

}

class _ReviewCommentWidgetState extends ConsumerState<ReviewCommentWidget>{
  late ValidatingTextEditingController _commentController = ValidatingTextEditingController();

  @override
  void initState(){
    super.initState();

    final newCommentState = ref.read(newCommentProvider);
    final newCommentNotifier = ref.read(newCommentProvider.notifier);
    _commentController = new ValidatingTextEditingController(
      initialValue: newCommentState,
      validator: newCommentNotifier.validateComment
    );
    _commentController.onAfterValidated = () => setState(() {});
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newCommentNotifier = ref.read(newCommentProvider.notifier);
    return TextField(
      controller: _commentController,
      maxLines: 3,
      decoration: InputDecoration(
        errorText: _commentController.errorText,
        labelText: 'Commentaire (optionnel)',
        border: OutlineInputBorder(),
        hintText: 'Très bonne expérience, je reviendrai !',
      ),
      onChanged: newCommentNotifier.setComment,
    );
  }
}
