import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/table_providers/selected_tables_provider.dart';

import '../../core/tools/abstract_async_notifier.dart';
import '../../models/table.dart';
import '../auth_provider.dart';

final tablesProvider =
AsyncNotifierProvider<TablesNotifier, SplayTreeSet<Table>>(
      () => TablesNotifier(),
);

class TablesNotifier extends AbstractAsyncNotifier<SplayTreeSet<Table>> {
  @override
  FutureOr<SplayTreeSet<Table>> build() async {
    // on doit regarder l'etat de connexion (si connecté en tant que manager ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    state = AsyncData(SplayTreeSet<Table>());
    state = AsyncLoading();

    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    try {
      if (authNotifier.isLoggedIn){
        final isManager = await authNotifier.isManager();
        if (isManager) // si on est un manager on va rechercher toutes les tables de la réservation
          return await Table.getTables(selectedRestaurant: selectedRestaurant);
      }
      return SplayTreeSet<Table>();
    }catch (e){
      throw "Something went wrong!\nPlease try again later.";
    }
  }

  @override
  Future<void> refresh() async{
    await getAll();
  }

  Future<void> getAll() async {
    state = AsyncLoading();
    try {
      final selectedTable = ref.read(selectedTableProvider);
      print('selected table is $selectedTable');
      final SplayTreeSet<Table> tables;

      final selectedRestaurant = ref.read(selectedRestaurantProvider);

      tables = await Table.getTables(selectedRestaurant: selectedRestaurant);
      state = AsyncData(tables);
    }
    catch (e){
      print(e);
      state = AsyncValue.error(
          'Something went wrong\nPlease try again later.',
          StackTrace.current
      );
    }
  }

  Future<bool?> is_occupee(int idtable, DateTime reservation_datetime) async {
    try {

      bool? response = await Table.is_occupee(idtable: idtable, reservation_datetime: reservation_datetime);
      return response;

    } catch (e){
      print(e);
      state = AsyncValue.error(
          'Something went wrong\nPlease try again later.',
          StackTrace.current
      );
    }
  }

  updateList(Table newTable) {
    state = AsyncLoading();
    final tables = state.value!;
    tables.removeWhere((table) => table.id == newTable.id);
    tables.add(newTable);
    state = AsyncData(tables);
  }
}