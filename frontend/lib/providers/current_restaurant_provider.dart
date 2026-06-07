import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';

final currentRestaurantProvider = AsyncNotifierProvider.autoDispose.family<CurrentRestaurantNotifier, Restaurant , int>(
  CurrentRestaurantNotifier.new,
);

// https://riverpod.dev/docs/concepts2/family -- EXPLICATION

class CurrentRestaurantNotifier extends AsyncNotifier<Restaurant> {
  CurrentRestaurantNotifier(this.id);
  final int id;

  @override
  Future<Restaurant> build() async {
    state = AsyncLoading();
    try {
      final response = await Restaurant.getRestaurant(id);
      state = AsyncData(response);
      return response;
    } catch(e, st) {
      AsyncError("Erreur ", st);
      throw Exception(e);
    }
  }
}
