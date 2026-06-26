import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/services.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/current_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/selected_restaurant_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/service.dart';
import 'auth_provider.dart';

final servicesPerDayProvider =
AsyncNotifierProvider<ServicesPerDayNotifier, SplayTreeMap<int, Services>>(
      () => ServicesPerDayNotifier(),
);

class ServicesPerDayNotifier extends AbstractAsyncNotifier<SplayTreeMap<int, Services>> {
  @override
  FutureOr<SplayTreeMap<int, Services>> build() async {
    // on doit regarder l'etat de connexion (si connecté en tant que manager ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    state = AsyncData(SplayTreeMap());
    state = AsyncLoading();

    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    try {
      if (authNotifier.isLoggedIn){
        final isManager = await authNotifier.isManager();
        if (isManager) // si on est un manager on va rechercher toutes les services du restaurant
          return await Service.getServices(selectedRestaurant: selectedRestaurant);
      }
      return SplayTreeMap();
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
    // on doit regarder l'etat de connexion (si connecté en tant que manager ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    try {
      if (authNotifier.isLoggedIn){
        final isManager = await authNotifier.isManager();
        if (isManager) { // si on est un manager on va rechercher toutes les services du restaurant
          final services = await Service.getServices(
              selectedRestaurant: selectedRestaurant);
          state = AsyncData(services);
        }
      }
      else {state = AsyncData(SplayTreeMap());}
    }catch (e){
      throw "Something went wrong!\nPlease try again later.";
    }
  }


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

  Future<void> deleteService(Service service) async {
    final deleted = await service.delete();
    if (deleted){
      state = AsyncLoading();
      // on va supprimer le service dans le treeset
      final newServicesPerDay = removeServiceFromDay(service);
      // on force la mise a jour du currentRestaurantProvider
      ref.read(currentRestaurantProvider(ref.read(selectedRestaurantProvider)).notifier).deleteService(service);
      // on actualise l'etat avec la nouvelle map contenant le treeset sans le service supprime
      state = AsyncData(newServicesPerDay);
    }
  }

  SplayTreeMap<int, Services> removeServiceFromDay(Service service){
    final servicesPerDay = state.value;
    final servicesOfTheDay = servicesPerDay![service.dayOfWeek];
    servicesOfTheDay!.remove(service);
    // on remplace l'ancien treeset avec le nouveau qui ne contient plus le servcice
    servicesPerDay[service.dayOfWeek] = servicesOfTheDay!;
    return servicesPerDay;
  }

  updateList(Service newService){
    state = AsyncLoading();
    var services = state.value;
    removeServiceFromDay(newService);
    services![newService.dayOfWeek]!.add(newService);
    state = AsyncData(services);
  }

  void updateState(SplayTreeMap<int, Services> servicesPerDay) {
    state = AsyncLoading();
    state = AsyncData(servicesPerDay);
  }
}