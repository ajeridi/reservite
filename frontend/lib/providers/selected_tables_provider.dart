

import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTableProvider =
  NotifierProvider<SelectedTableNotifier, int>(
      () => SelectedTableNotifier(),
);

class SelectedTableNotifier extends Notifier<int>{
  @override
  int build() {
    return 0;
  }

  void set(int newId){
    state = newId;
  }

}