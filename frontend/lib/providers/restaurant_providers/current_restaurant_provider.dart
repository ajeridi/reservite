import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/models/service.dart';
import 'package:prbd_2526_a07/providers/reservation_providers/reservations_provider.dart';
import 'package:prbd_2526_a07/providers/restaurant_providers/restaurants_provider.dart';

final currentRestaurantProvider = AsyncNotifierProvider.autoDispose.family<CurrentRestaurantNotifier, Restaurant , int>(
  CurrentRestaurantNotifier.new,
);

// https://riverpod.dev/docs/concepts2/family -- EXPLICATION

class CurrentRestaurantNotifier extends AsyncNotifier<Restaurant> {
  CurrentRestaurantNotifier(this.id);
  final int id;

  @override
  Future<Restaurant> build() async {
    try {
      final response = await Restaurant.getRestaurant(id);
      state = AsyncData(response);
      return response;
    } catch(e, st) {
      AsyncError("Erreur ", st);
      throw Exception(e);
    }
  }
  Future<String?> toggle() async{
    final response = await state.value!.toggle();
    //si c'est un string, ca veut dire message d'erreur
    if(response is String){
      return response;
    }
    final resto = response as Restaurant;
    //si c'est un restaurant avec isSponsored a jour
    print("currentREservationNotifier methode toggle");
    ref.read(restaurantProvider.notifier).updateResto(resto);
  }



  deleteService(Service service) {
      state = AsyncLoading();
      final restaurant = state.value!;
      restaurant.deleteService(service);
      state = AsyncData(restaurant);
  }
}
