import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/reservation.dart';

final reservationsProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<Reservation>>(
        () => ReservationsNotifier(),
    );

class ReservationsNotifier extends AsyncNotifier<List<Reservation>>{
  @override
  FutureOr<List<Reservation>> build() async {
    state = AsyncData(<Reservation>[]);
    state = AsyncLoading();
    try {
      return await Reservation.getReservations();
    }catch (e){
      throw "Something went wrong!\nPlease try again later.";
    }
  }

}