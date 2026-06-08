import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/providers/selected_restaurant_provider.dart';
import 'package:prbd_2526_a07/providers/selected_tables_provider.dart';

import '../core/tools/abstract_async_notifier.dart';
import '../models/services.dart';
import 'auth_provider.dart';

final servicesProvider =
AsyncNotifierProvider<ServicesNotifier, List<Services>>(
      () => ServicesNotifier(),
);

class ServicesNotifier extends AbstractAsyncNotifier<List<Services>> {
  @override
  FutureOr<List<Services>> build() async {
    // on doit regarder l'etat de connexion (si connecté en tant que manager ou non)
    ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    state = AsyncData(<Services>[]);
    state = AsyncLoading();

    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    try {
      if (authNotifier.isLoggedIn){
        final isManager = await authNotifier.isManager();
        if (isManager) // si on est un manager on va rechercher toutes les services de la réservation
          return await Services.getServices(selectedRestaurant: selectedRestaurant);
      }
      return <Services>[];
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
      final selectedService = ref.read(selectedTableProvider);
      print('selected service is $selectedService');
      final List<Services> services;

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

  Future<bool?> is_empty(int day_of_weekk, int restaurantid) async {
    try {

      bool? response = await Services.is_empty(day_of_weekk: day_of_weekk, restaurantid: restaurantid);
      return response;

    } catch (e){
      print(e);
      state = AsyncValue.error(
          'Something went wrong\nPlease try again later.',
          StackTrace.current
      );
    }
  }

  Future<bool?> canDelete(int serviceId) async {
    try {
      return await Services.canDelete(serviceId: serviceId);
    } catch (e) {
      print(e);
      state = AsyncValue.error(
        'Something went wrong\nPlease try again later.',
        StackTrace.current,
      );
    }
    return null;
  }

  Future<Services> create({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final selectedRestaurant = ref.read(selectedRestaurantProvider);
    final created = await Services.create(
      restaurantId: selectedRestaurant,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
    await refresh();
    return created;
  }

  Future<bool> delete(int serviceId) async {
    try {
      final ok = await Services.delete(serviceId: serviceId);
      if (ok) {
        final selectedRestaurant = ref.read(selectedRestaurantProvider);
        final updatedServices = await Services.getServices(
          selectedRestaurant: selectedRestaurant,
        );
        state = AsyncData(updatedServices);
      }
      return ok;
    } catch (e) {
      print(e);
      state = AsyncValue.error(
        'Something went wrong\nPlease try again later.',
        StackTrace.current,
      );
    }
    return false;
  }
}