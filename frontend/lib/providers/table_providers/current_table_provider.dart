import 'dart:async';

import 'package:flutter/material.dart' hide Table;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/crudl_table_providers/new_table_number_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/table_providers/selected_table_id_provider.dart';
import 'package:prbd_2526_a07/providers/table_providers/tables_provider.dart';

import '../../core/tools/abstract_async_notifier.dart';
import '../../models/table.dart';

final currentTableProvider = AsyncNotifierProvider.autoDispose
    .family<CurrentTableNotifier, Table?, int>(
  // autoDispose pour detruire le provider une fois qu'on ne l'utilise plus
  CurrentTableNotifier.new,
);

class CurrentTableNotifier extends AbstractAsyncNotifier<Table?> {
  CurrentTableNotifier(this.id);

  final int id;

  @override
  FutureOr<Table?> build() async {
    state = AsyncData(null);
    state = AsyncLoading();
    try {
      final restaurantId = ref.watch(selectedRestaurantProvider);
      return id != 0 ? await Table.getTable(id, restaurantId) : null;
    } catch (e, st) {
      throw Exception("Something went wrong.\nPlease retry later.");
    }
  }

  @override
  Future<void> refresh() async {
    state = AsyncLoading();
    try {
      final restaurantId = ref.watch(selectedRestaurantProvider);
      final reservation = await Table.getTable(id, restaurantId);
      state = AsyncData(reservation);
    } catch (e, st) {
      print('$e\n$st');
      throw Exception("Failed to refresh the table");
    }
  }

  Future<bool> validateAll(int? newTableNumber) async {
    final String newTableNumberString = (newTableNumber != null ? '${newTableNumber}' : '');
    if (Table.validateTableNumber(newTableNumberString) != null) return false;

    final tableId = ref.read(selectedTableIdProvider);
    final selectedRestaurantId = ref.read(selectedRestaurantProvider);
    if (await Table.checkTableNumberUnicity(newTableNumberString, tableId, selectedRestaurantId) != null) return false;

    return true;
  }

  Future<void> saveTable(int? newTableNumber, int newCapacity) async {
    final tableId = state.value == null ? 0 : state.value!.id;
    final restaurantId = ref.watch(selectedRestaurantProvider);
    final newTable = await Table.save_table(newTableNumber, newCapacity, tableId, restaurantId);

    ref.read(tablesProvider.notifier).updateList(newTable);
  }
}