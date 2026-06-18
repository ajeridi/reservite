import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/services.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/selected_services_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/service.dart';
import 'auth_provider.dart';

final servicesPerDayProvider =
AsyncNotifierProvider<ServicesPerDayNotifier, Map<int, Services>>(
      () => ServicesPerDayNotifier(),
);

class ServicesPerDayNotifier extends AbstractAsyncNotifier<Map<int, Services>> {
  @override
  FutureOr<Map<int, Services>> build() async {
    // on doit regarder l'etat de connexion (si connecté en tant que manager ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    state = AsyncData(HashMap());
    state = AsyncLoading();

    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    try {
      if (authNotifier.isLoggedIn){
        final isManager = await authNotifier.isManager();
        if (isManager) // si on est un manager on va rechercher toutes les services du restaurant
          return await Service.getServices(selectedRestaurant: selectedRestaurant);
      }
      return HashMap();
    }catch (e){
      throw "Something went wrong!\nPlease try again later.";
    }
  }

  @override
  Future<void> refresh() async{
    //await getAll();
  }

/*
  Future<void> getAll() async {
    state = AsyncLoading();
    try {
      final selectedService = ref.read(selectedServiceIdProvider);
      print('selected service is $selectedService');
      final SplayTreeSet<Service> services;

      final selectedRestaurant = ref.read(selectedRestaurantProvider);

      services = await Service.getServices(selectedRestaurant: selectedRestaurant);
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
*/

/*
  updateList(Service newService) {
    state = AsyncLoading();
    final services = state.value!;
    services.removeWhere((table) => table.id == newService.id);
    services.add(newService);
    state = AsyncData(services);
  }
*/

  String getJour(int day_of_week) {
    if (day_of_week == 1)
      return 'Lundi';
    if (day_of_week == 2)
      return 'Mardi';
    if (day_of_week == 3)
      return 'Mercredi';
    if (day_of_week == 4)
      return 'Jeudi';
    if (day_of_week == 5)
      return 'Vendredi';
    if (day_of_week == 6)
      return 'Samedi';
    if (day_of_week == 7)
      return 'Dimanche';

    return '';
  }
}