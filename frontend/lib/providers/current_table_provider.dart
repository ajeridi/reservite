

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/table.dart';

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
}