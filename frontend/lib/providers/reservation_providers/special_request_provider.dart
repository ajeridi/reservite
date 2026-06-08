import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

import '../../models/reservation.dart';

final specialRequestProvider = AsyncNotifierProvider<SpecialRequestNotifier, String>(
  SpecialRequestNotifier.new,
);

class SpecialRequestNotifier extends AsyncNotifier<String>{
  @override
  FutureOr<String> build() async {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);

    // si en mode add on retourne ''
    if (selectedReservationId == 0)
      return '';

    // sinon en mode edit, on retourne la special request de la reservation en cours de modfication
    final currentReservationState = await ref.watch(currentReservationProvider(selectedReservationId).future);
    final currentReservationSpecialRequests = currentReservationState!.specialRequests;
    // si par defaut le special request de la reservation est null on retourne un string vide
    return currentReservationSpecialRequests ?? '';
  }

  void setSpecialRequest(String value) {
    state = AsyncData(value);
  }

  String? validate(String? value) {
    return Reservation.validateSpecialRequests(value);
  }

  void clear() {
    state = AsyncData('');
  }

  bool isValid() {
    final specialRequest = state.value!;
    return Reservation.validateSpecialRequests(specialRequest) == null;
  }


}
