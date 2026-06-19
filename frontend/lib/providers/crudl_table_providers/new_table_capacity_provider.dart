import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/table_providers/current_table_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/table_providers/selected_table_id_provider.dart';

final newTableCapacityProvider = NotifierProvider<NewTableCapacityNotifier, int>(
    () => NewTableCapacityNotifier(),
);

class NewTableCapacityNotifier extends Notifier<int>{
  @override
  int build() {
    final selectedTableId = ref.watch(selectedTableIdProvider);
    final currentTable = ref.watch(currentTableProvider(selectedTableId));
    if (currentTable.value == null) return 2;
    return currentTable.value!.capacity;
  }

  void increment() {
    state++;
  }

  void decrement() {
    state--;
  }

  int getMinimumCapacity() {
    final currentTable = ref.watch(currentTableProvider(ref.watch(selectedTableIdProvider)));
    if (currentTable.value != null && currentTable.value!.hasReservations!) return currentTable.value!.capacity;
    return 1;
  }

  // methode qui va retourner la "raison" pourquoi on ne peut plus decrementer la capacity
  String? reasonOfNotDecrementing() {
    if (state > getMinimumCapacity()) return null; // si la capacite est au dessus de la capacite minumum, pas de raison d'affichage du tooltip

    final currentTable = ref.watch(currentTableProvider(ref.watch(selectedTableIdProvider)));
    final String baseReason = 'La capacite minimale est de 1';
    if ( currentTable.value != null && currentTable.value!.hasReservations!) return 'Impossible de diminuer la capacité, une ou plusieurs réservations utilisent cette table et nécessitent au moins cette capacité.';
    return baseReason;
  }

}