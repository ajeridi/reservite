import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

import '../../models/reservation.dart';

final specialRequestProvider = NotifierProvider<SpecialRequestNotifier, String>(
  SpecialRequestNotifier.new,
);

class SpecialRequestNotifier extends Notifier<String> {
  @override
  String build() {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);

    // si en mode add on retourne ''
    if (selectedReservationId == 0)
      return '';

    // sinon en mode edit, on retourne la special request de la reservation en cours de modfication
      final currentReservationState = ref.watch(currentReservationProvider(selectedReservationId));
      return currentReservationState.value!.specialRequests!;
  }

  void setSpecialRequest(String value) {
    state = value;
  }

  String? validate(String? value) {
    return Reservation.validateSpecialRequests(value);
  }

  void clear() {
    state = '';
  }
}
