

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';
import 'package:prbd_2526_a07/providers/services_provider.dart';
import 'package:prbd_2526_a07/providers/tables_provider.dart';

import '../models/table.dart';

final selectedServiceProvider =
NotifierProvider<SelectedServiceNotifier, int>(
      () => SelectedServiceNotifier(),
);

class SelectedServiceNotifier extends Notifier<int>{
  @override
  int build() {
    return 0;
  }

  void set(int newId) {
    state = newId;
  }

  void clear() {
    state = 0;
  }

}