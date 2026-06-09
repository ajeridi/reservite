import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/review_providers/new_comment_provider.dart';

final IsValidCommentProvider = NotifierProvider.autoDispose<IsValidCommentNotifier,bool>(
    () => IsValidCommentNotifier()
);

class IsValidCommentNotifier extends Notifier<bool> {

  @override
  bool build() {
    final newComment = ref.watch(newCommenrProvider);
    final newCommentNotifier = ref.watch(newCommenrProvider.notifier);

    return newComment == null || newCommentNotifier.validateComm(newComment) == null;
  }
}