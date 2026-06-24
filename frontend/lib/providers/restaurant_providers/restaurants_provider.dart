

import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/providers/auth_provider.dart';

import '../../core/tools/abstract_async_notifier.dart';

final restaurantProvider = AsyncNotifierProvider<RestaurantsNotifier, SplayTreeSet<Restaurant>>(
        () => RestaurantsNotifier(),
);

class RestaurantsNotifier extends AbstractAsyncNotifier<SplayTreeSet<Restaurant>>{
  @override
  Future<SplayTreeSet<Restaurant>> build() async {
    // il faut observer l'etat de la connexion, car la liste des restaurants doit changer quand on change de manager
    ref.watch(authProvider);
    state = AsyncData(SplayTreeSet<Restaurant>());
    state = AsyncLoading();
    print("Resto provider -build- avant try");
    try {
      return SplayTreeSet<Restaurant>.from(await Restaurant.getRestaurants());
    }catch(e) {
      print(e);
      throw "Something went really wrong!\nPlease try again later.";
    }
  }



  Future<void> getRestaurants() async {
    state = const AsyncValue.loading();

    try{
      final restaurants = SplayTreeSet<Restaurant>.from(await Restaurant.getRestaurants());
      state = AsyncData(restaurants);
    }catch (e){
      print(e);
      state = AsyncValue.error("Something went really wrong!\nPlease try again later.", StackTrace.current,);
    }
  }

  @override
  Future<void> refresh() async{
    await getRestaurants();
  }

  void updateResto(Restaurant updatedRestaurant){
    state = AsyncLoading();
    final restaurants = state.value; // liste actuelle dans l'etat
    var newRestaurant; // va contenir la nouvelle copie de la reservation a modifier
    // on va chercher la reservation a copier
    for(var restaurant in restaurants!){
    if(restaurant.id == updatedRestaurant.id){
    // copie de la reservation a modifier avec le nouveau statut
    newRestaurant = restaurant.copyWith(isSponsored: updatedRestaurant.isSponsored);
    }
    }
    // suppression de la reservation obsolete
    restaurants.removeWhere((res) => res.id == updatedRestaurant.id);
    // rajout de la nouvelle reservation mise a jour
    restaurants.add(newRestaurant);
    // modification de la liste de l'etat
    state = AsyncData(restaurants);
  }
}

