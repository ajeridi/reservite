// Provider qui va fournir la date simulee de l'application


import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/models/application_time.dart';

final applicationTimeProvider = AsyncNotifierProvider<ApplicationTimeNotifier, DateTime>(
    () => ApplicationTimeNotifier(),
);

class ApplicationTimeNotifier extends AbstractAsyncNotifier<DateTime>{
  @override
  Future<DateTime> build() async {
    state = AsyncData(DateTime.now());
    state = AsyncLoading();
    try {
      return await ApplicationTime.get();
    }catch (e, st){
      debugPrint('$e\n$st');
      throw Exception('Something went wrong.\nPlease try again later.');
    }
  }

  @override
  Future<void> refresh() async {
    state = AsyncLoading();
    try {
      var simulatedTime = await ApplicationTime.get();
      state = AsyncData(simulatedTime);
    } catch (e, st){
      debugPrint('$e\n$st');
      throw Exception('Something went wrong.\nPlease try again later.');
    }
  }

  //update time localement
  void setTime(DateTime newTime) async {
    state = AsyncData(newTime);
    // update dans la base de donnee du nouveau temps
    await ApplicationTime.saveTime(newTime);
  }

}