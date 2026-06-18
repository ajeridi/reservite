
import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/core/tools/abstract_async_notifier.dart';
import 'package:prbd_2526_a07/models/services.dart';
import 'package:prbd_2526_a07/providers/crudl_service_providers/selected_services_provider.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/selected_reservation_id_provider.dart';

import '../auth_provider.dart';
import '../selected_restaurant_provider.dart';

final servicesProvider = AsyncNotifierProvider<ServicesNotifier,SplayTreeSet<Services>>(
    () => ServicesNotifier(),
);

class ServicesNotifier extends AbstractAsyncNotifier<SplayTreeSet<Services>>{

  FutureOr<SplayTreeSet<Services>> build() async{
    // on doit regarder l'etat de connexion (si connecté en tant que manager ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    state = AsyncData(SplayTreeSet<Services>());
    state = AsyncLoading();

    final selectedRestaurant = ref.watch(selectedReservationIdProvider);
    try{
      if (authNotifier.isLoggedIn) {
        final isManager = await authNotifier.isManager();
        if (isManager) {
          // si on est un manager on va rechercher toutes les services du restaurant
          return await Services.getServices(
              selectedRestaurant: selectedRestaurant);
        }
      }
      return SplayTreeSet<Services>();
    }catch(e){
      throw "Something went wrong with getServices!\nPlease try again later.";
    }


  }

  @override
  Future<void> refresh() async{
    // TODO: implement refresh
    await getAll();
  }

  Future<void> getAll() async {
    state = AsyncLoading();
    try {
      final selectedService = ref.read(selectedServiceProvider);
      print('selected service is $selectedService');
      final SplayTreeSet<Services> services;

      final selectedRestaurant = ref.read(selectedRestaurantProvider);

      services = await Services.getServices(selectedRestaurant: selectedRestaurant);
      state = AsyncData(services);
    }
    catch (e){
      print(e);
      state = AsyncValue.error(
          'Something went wrong\nPlease try again later.',
          StackTrace.current
      );
    }
  }

  Future<bool?> is_not_empty(int idservice, DateTime reservation_datetime) async {
    try {

      bool? response = await Services.is_not_empty(idservice: idservice, reservation_datetime: reservation_datetime);
      return response;

    } catch (e){
      print(e);
      state = AsyncValue.error(
          'Something went wrong\nPlease try again later.',
          StackTrace.current
      );
    }
  }

  updateList(Services newService){
    state = AsyncLoading();
    final serv = state.value!;
    serv.removeWhere((service) => service.id == newService.id);
    serv.add(newService);
    state = AsyncData(serv);
  }

}