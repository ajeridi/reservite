
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/providers/restaurants_provider.dart';

final filteredRestaurantsProvider =
  NotifierProvider<FilteredRestaurantsNotifier, SplayTreeSet<Restaurant>>(() => FilteredRestaurantsNotifier(),);

class FilteredRestaurantsNotifier extends Notifier<SplayTreeSet<Restaurant>>{


  @override
  SplayTreeSet<Restaurant> build() {
    final restaurants = ref.watch(restaurantProvider);

    //retourne seulement quand restaurants a des data
    return restaurants.when(data: (data){ return getFilteredRestaurants(data, '');},
        error: (err,_) =>SplayTreeSet<Restaurant>(),
        loading: () => SplayTreeSet<Restaurant>());
  }

  SplayTreeSet<Restaurant> getFilteredRestaurants(SplayTreeSet<Restaurant> restaurants , String search){
    SplayTreeSet<Restaurant> filteredRestaurants = SplayTreeSet<Restaurant>();
    for(var restaurant in restaurants){
      print(search == restaurant.name.toLowerCase());
      if(search == '' || restaurant.name.toLowerCase().contains(search.toLowerCase()) || restaurant.city!.toLowerCase().contains(search.toLowerCase()) || restaurant.description!.toLowerCase().contains(search.toLowerCase())) {
        filteredRestaurants.add(restaurant);
      }
    }
    return filteredRestaurants;
  }

  void updateFilter(SplayTreeSet<Restaurant> restos , String search){
    state = getFilteredRestaurants(restos, search);
  }


  SplayTreeSet<Restaurant> refresh(String search) {
    final restaurants = ref.watch(restaurantProvider);
    return restaurants.when(data: (data) {
      updateFilter(data, search);
      return state;
    },
        error: (err, _) => SplayTreeSet<Restaurant>(),
        loading: () => SplayTreeSet<Restaurant>());
  }
}