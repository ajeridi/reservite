

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/reviews_provider.dart';
import 'package:prbd_2526_a07/providers/tables_provider.dart';

import '../models/table.dart';

final selectedStarProvider =
NotifierProvider<SelectedStarNotifier, double>(
      () => SelectedStarNotifier(),
);

class SelectedStarNotifier extends Notifier<double>{
  @override
  double build() {
    final reviewsState = ref.watch(reviewsProvider);
    if (reviewsState.value == null) {
      return 3.0;
    }

    return reviewsState.value!.rating.toDouble();
  }

  void setState(double nouvelleValeur) {
    state = nouvelleValeur;
  }

  void clear() {
    state = 3.0;
  }

  double getState() {
    return state;
  }

}