/*
* Provider qui va fournir l'id de la reservation selectionnee
* */

import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedReservationIdProvider =
    NotifierProvider<SelectedReservationIdNotifier, int>(
      () => SelectedReservationIdNotifier(),
    );

class SelectedReservationIdNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void set(int newId) {
    state = newId;
  }

  void clear(){
    state = 0;
  }
}
