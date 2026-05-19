import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/core/services/api_client.dart';
import 'package:prbd_2526_a07/core/tools/params.dart';

class Restaurant implements Comparable<Restaurant>{
  final int id;
  final String name;
  final String address;
  final String? city;
  final String? phone;
  final String? description;
  final double? rating;
  final int? priceRange;
  final int? slotDuration;
  final DateTime? date;
  final int? reservPending;

  // constructeur
  const Restaurant({
    required this.id,
    required this.name,
    this.address = '',
    this.city = '',
    this.phone = '',
    this.description = '',
    this.rating = 0,
    this.priceRange = 0,
    this.slotDuration = 0,
    required this.date ,
    this.reservPending = 0,
  });

  String getLastDate (){
    String day = DateFormat('EE dd/MM/yyyy').format(this.date);
    return day;
  }

  String getPriceRange (){
    String result='';
    if(priceRange != null) {
      for (int i = 0; i < priceRange!; i++)
        result += '€';
    }
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
      priceRange: json['price_range'],
      slotDuration: json['slot_duration'],
      date: json['last_reservation_date'] != null ? DateTime.parse(json['last_reservation_date']) : null,
      reservPending: json['reservations_pending'] as int?,
    );
  }

  // construit un objet Restaurant avec le json venant de reservations
  static Restaurant makeRestaurantOfReservation(Map<String, dynamic>json){
    return Restaurant(
        id : json['id'],
        name: json['name'],
        city: json['city'],
        date: DateTime.now());
  }

  static Future<Restaurant> getRestaurant() async{
    //Params.setValue('token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiY2xpZW50Iiwic3ViIjoieGFwaWdlb2xldEBlcGZjLmV1IiwibmFtZSI6IlhhdmllciIsInVzZXJfaWQiOjMsImV4cCI6MTc3OTIyNTY5N30.Wx5NOHWxu7rsmkq4xbh_xvvHuCPuDdrfcg2PmQC9KuQ');
    final response = await ApiClient.get('get_restaurant');
    if(response.statusCode == 200) {
      return Restaurant.fromJson(json.decode(response.body));
    }else{
      throw Exception('Failed to get restaurant');
    }
  }

  static Future<List<Restaurant>> getRestaurants() async{
    //Params.setValue('token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiY2xpZW50Iiwic3ViIjoieGFwaWdlb2xldEBlcGZjLmV1IiwibmFtZSI6IlhhdmllciIsInVzZXJfaWQiOjMsImV4cCI6MTc3OTIyNTY5N30.Wx5NOHWxu7rsmkq4xbh_xvvHuCPuDdrfcg2PmQC9KuQ');
    final response = await ApiClient.get('get_restaurants');
    if(response.statusCode == 200){
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Restaurant.fromJson(item)).toList();
    }else{
      throw Exception('Failed to get the restaurants');
    }
  }
}