
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/models/services.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';
final servicesProvider = AsyncNotifierProvider<ServicesNotifier,List<Services>>( () => ServicesNotifier(),);

class ServicesNotifier extends AbstractAsyncNotifier<List<Services>> {
  @override
  FutureOr<List<Services>> build() async{
    // TODO: implement build
    final restaurantId = ref.watch(selectedRestaurantProvider);
    try{
      return await Services.getServices(restaurantId);
    }catch(e,st){
      debugPrint('$e\n$st');
      throw Exception('Something went wrong? Please try later');
    }
  }

  @override
  Future<void> refresh() async{
    state = AsyncLoading();
    final restaurantId = ref.read(selectedRestaurantProvider);
    try{
      state = AsyncData(await Services.getServices(restaurantId));
    }catch(e,st){
      debugPrint('$e\n$st');
      state = AsyncError(e, st);
    }
  }
  
  //insert or update - reçoit le service mis à jour depuis l'API
  Future<void> save(int? serviceId, int restaurantId,int dayOfWeek, String startTime, String endTime) async{
    try{
      final saved = await Services.save(serviceId, restaurantId, dayOfWeek, startTime, endTime);
      final current = state.value ?? [];
      if(serviceId == null){
        // insert a la liste
        state = AsyncData([...current,saved]);
      }else{
        //update
        state = AsyncData([
          for(var s in current)
            if(s.id == serviceId)
              saved
            else
              s,
        ]);
      }
    }catch(e,st){
      debugPrint('$e\n$st');
      throw Exception('Something went wrong? Please try later');
    }
  }
  
  //delete
  Future<void> delete(int serviceId) async{
    try{
      await Services.delete(serviceId);
      final current = state.value ?? [];
      state = AsyncData(current.where((s) => s.id != serviceId).toList());
    }catch(e,st){
      debugPrint('$e\n$st');
      throw Exception('Something went wrong.\nPlease try again later.');
    }
  }
  
}