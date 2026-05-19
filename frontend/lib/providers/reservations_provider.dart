import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/models/reservation.dart';

final reservationsProvider =
    AsyncNotifierProvider<ReservationsNotifier, List<Reservation>>(
        () => ReservationsNotifier(),
    );

class ReservationsNotifier extends AbstractAsyncNotifier<List<Reservation>>{
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

  @override
  Future<void> refresh() async{
    await getAll();
  }

  Future<void> getAll() async {
    state = AsyncLoading();
    try {
      final reservations = await Reservation.getReservations();
      state = AsyncData(reservations);
    }
    catch (e){
      print(e);
      state = AsyncValue.error(
          'Something went wrong\nPlease try again later.',
          StackTrace.current
      );
    }
  }

}