import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/current_table_provider.dart';
import 'package:prbd_2526_a07/providers/selected_table_id_provider.dart';

final newTableNumberProvider = NotifierProvider<NewTableNumberNotifier, int?>(
    () => NewTableNumberNotifier(),
);

class NewTableNumberNotifier extends Notifier<int?>{
  @override
  int? build() {
    final currentTableState = ref.watch(currentTableProvider(ref.watch(selectedTableIdProvider)));

    if (currentTableState.value == null) return null;
    return currentTableState.value!.tableNumber;
  }

  void setValue(String value) {
    final number = int.tryParse(value);
    state = number;
  }

}