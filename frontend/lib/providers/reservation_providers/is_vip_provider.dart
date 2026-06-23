import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

final isVipProvider =
NotifierProvider.autoDispose<IsVipNotifier, bool>(
  IsVipNotifier.new,
);

class IsVipNotifier extends Notifier<bool> {
  @override
  bool build() {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);

    if (selectedReservationId == 0)
      return false;

    final currentReservation = ref.watch(currentReservationProvider(selectedReservationId)).asData;
    return currentReservation!.value!.is_vip;
  }

  void setVip(bool value) {
    state = value;
  }
}