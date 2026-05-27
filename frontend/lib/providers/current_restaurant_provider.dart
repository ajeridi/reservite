import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';

final currentRestaurantProvider = FutureProvider.autoDispose.family<Restaurant , int>((ref , id) async{
  final response = await Restaurant.getRestaurant(id);
  return response;
});
