import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/models/service.dart';

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

  deleteService(Service service) {
      state = AsyncLoading();
      final restaurant = state.value!;
      restaurant.deleteService(service);
      state = AsyncData(restaurant);
  }
}
