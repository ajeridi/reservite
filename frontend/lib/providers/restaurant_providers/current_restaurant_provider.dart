import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/models/service.dart';
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

  deleteService(Service service) {
      state = AsyncLoading();
      final restaurant = state.value!;
      restaurant.deleteService(service);
      state = AsyncData(restaurant);
  }

  Future<Restaurant> sponsored_true(int restaurant_id) async {
    final sponsored_true = await Restaurant.sponsored_true(
      restaurantId: restaurant_id,
    );

    state = AsyncData(sponsored_true);

    // mettre a jour directement la liste soit en ajoutant si nouveau restaurant, soit en supprimant et en rajoutant la nouvelle
    ref.read(restaurantProvider.notifier).addOrUpdateRestaurant(sponsored_true);

    return sponsored_true;
  }

  Future<Restaurant> sponsored_false(int restaurant_id) async {
    final sponsored_false = await Restaurant.sponsored_false(
      restaurantId: restaurant_id,
    );

    state = AsyncData(sponsored_false);

    // mettre a jour directement la liste soit en ajoutant si nouveau restaurant, soit en supprimant et en rajoutant la nouvelle
    ref.read(restaurantProvider.notifier).addOrUpdateRestaurant(sponsored_false);

    return sponsored_false;
  }
}
