import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/core/services/api_client.dart';

class Restaurant implements Comparable<Restaurant>{
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String description;
  final double rating;
  final int price_range;
  final int slot_duration;
  final DateTime date;
  final int reservPending;

  // constructeur
  const Restaurant({
    this.id = 0,
    this.name = '',
    this.address = '',
    this.city = '',
    this.phone = '',
    this.description = '',
    this.rating = 0,
    this.price_range = 0,
    this.slot_duration = 0,
    required this.date,
    this.reservPending = 0,
  });

  String getLastDate (){
    String day = DateFormat('EE dd/MM/yyyy').format(this.date);
    return day;
  }

  String getPriceRange (){
    String result='';
    for(int i=0;i<price_range;i++)
      result +='€';
    return  result;
  }

  @override
  int compareTo(Restaurant other) {
    return this.date==other.date? this.name.compareTo(other.name) : this.date.compareTo(other.date);
  } // constructeur Json
  factory Restaurant.fromJson(Map<String, dynamic> json){
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      city: json['city'],
      description: json['description'],
      rating: json['rating'],
      price_range: json['price_range'],
      slot_duration: json['slot_duration'],
      date: DateTime.parse(json['last_reservation_date']),
      reservPending: json['reservations_pending'],
    );
  }

  static Future<Restaurant> getRestaurant() async{
    final response = await ApiClient.get('get_restaurant');
    if(response.statusCode == 200) {
      return Restaurant.fromJson(json.decode(response.body));
    }else{
      throw Exception('Failed to get restaurant');
    }
  }

  static Future<List<Restaurant>> getRestaurants() async{
    final response = await ApiClient.get('get_restaurants');
    if(response.statusCode == 200){
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    }else{
      throw Exception('Failed to get the restaurants');
    }
  }
}