

import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTableProvider =
  NotifierProvider<SelectedTableNotifier, Set<int>>(
      () => SelectedTableNotifier(),
);

class SelectedTableNotifier extends Notifier<Set<int>>{
  @override
  Set<int> build() {
    return {};
  }

  void toggle(int tableId) {
    if (state.contains(tableId)) {
      state = {...state}..remove(tableId);
    } else {
      state = {...state, tableId};
    }
  }

  void clear() {
    state = {};
  }

}