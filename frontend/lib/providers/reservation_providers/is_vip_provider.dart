

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/current_reservation_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

final isVipProvider = AsyncNotifierProvider<IsVipNotifier,bool>(
  IsVipNotifier.new,
);

class IsVipNotifier extends AsyncNotifier<bool> {

  @override
  FutureOr<bool> build() async {
    final selectedReservationId = ref.watch(selectedReservationIdProvider);

    final currentReservationState = await ref.watch(currentReservationProvider(selectedReservationId).future);
    final currentIsVipValue = currentReservationState!.isVip;

    return currentIsVipValue;
  }

  void setIsVip(bool value){
    state = AsyncData(value);
  }
}