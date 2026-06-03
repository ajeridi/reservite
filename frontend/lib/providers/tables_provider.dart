import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/selected_tables_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/table.dart';
import 'auth_provider.dart';

final tablesProvider =
AsyncNotifierProvider<TablesNotifier, List<Table>>(
      () => TablesNotifier(),
);

class TablesNotifier extends AbstractAsyncNotifier<List<Table>> {
  @override
  FutureOr<List<Table>> build() async {
    // on doit regarder l'etat de connexion (si connecté en tant que manager ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    state = AsyncData(<Table>[]);
    state = AsyncLoading();
    try {
      if (authNotifier.isLoggedIn){
        final isManager = await authNotifier.isManager();
        if (isManager) // si on est un manager on va rechercher toutes les tables de la réservation
          return await Table.getTables();
      }
      return <Table>[];
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
      final authNotifier = ref.read(authProvider.notifier);

      final selectedTable = ref.read(selectedTableProvider);
      print('selected restaurant is $selectedTable');
      final List<Table> tables;

      tables = await Table.getTables();
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
}