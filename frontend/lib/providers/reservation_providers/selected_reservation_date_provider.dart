import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/application_time_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

import '../../models/reservation.dart';

final selectedReservationDateProvider = AsyncNotifierProvider(
  () => SelectedReservationDateNotifier(),
);

// Va represente la date potentielle d'une nouvelle reservation, s'occupera de stocker le DateTime d'une reservation en cours d'edition
class SelectedReservationDateNotifier extends AsyncNotifier<DateTime> {
  @override
  FutureOr<DateTime> build() async {
    final applicationTime = ref.watch(applicationTimeProvider);
    final currentReservation = ref.watch(
      currentReservationProvider(ref.watch(selectedReservationIdProvider)),
    );
    // si la reservation courante existe deja, on peut deja prendre son date time
    if (currentReservation.value!.id != 0) {
      return currentReservation.value!.datetime;
    }
    // sinon on prends le date time de l'application
    try {
      return applicationTime.value!;
    } catch (e, st) {
      print('$e\n$st');
      throw Exception('Failed to get first available reservation date');
    }
  }

  void setDate(DateTime pickedDate) {
    state = AsyncLoading();
    state = AsyncData(pickedDate);
  }

  void addDay() {
    state = AsyncLoading();
    state = AsyncData(state.value!.add(const Duration(days: 1)));
  }

  void subtractDay() {
    state = AsyncLoading();
    state = AsyncData(state.value!.subtract(const Duration(days: 1)));
  }
}
