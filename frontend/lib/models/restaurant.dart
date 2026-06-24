import 'dart:collection';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/core/services/api_client.dart';
import 'package:prbd_2526_a07/models/service.dart';


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
  final bool isSponsored;
  final DateTime? date;
  final int? reservPending;
  final SplayTreeSet<Service>? services;

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
    required this.isSponsored,
    required this.date ,
    this.reservPending = 0,
    this.services = null,
  });

  Restaurant copyWith( {
    int? id,
    String? name,
    String? address,
    String? city,
    String? phone,
    String? description,
    double? rating,
    int? priceRange,
    int? slotDuration,
    bool? isSponsored,
    DateTime? date,
    int? reservPending,
    SplayTreeSet<Service>? services}){
    return Restaurant(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        city: city ?? this.city,
        phone: phone ?? this.phone,
        description: description ?? this.description,
        rating: rating ?? this.rating,
        priceRange: priceRange ?? this.priceRange,
        slotDuration: slotDuration ?? this.slotDuration,
        isSponsored: isSponsored ?? this.isSponsored,
        date: date ?? this.date,
        reservPending: reservPending ?? this.reservPending,
        services: services ?? this.services);
  }

  String getLastDate (){
    DateTime? date = this.date;
    if (date == null) return '';
    String day = DateFormat('EE dd/MM/yyyy').format(date);
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
    DateTime? date = this.date;
    DateTime? otherDate = other.date;
    if (date==null && otherDate == null) return 0;
    if (date == null) return -1;
    if (otherDate == null) return 1;
    return this.date==other.date? this.name.compareTo(other.name) : otherDate.compareTo(date);
  }




  // constructeur Json
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
      isSponsored: json['is_sponsored'],
      date: json['last_reservation_date'] != null ? DateTime.parse(json['last_reservation_date']) : null,
      reservPending: json['reservations_pending'] as int?,
      services:  json['services'] == null ? null : Service.servicesFromJson (json ['services' ]),
    );
  }

  // construit un objet Restaurant avec le json venant de reservations
  static Restaurant makeRestaurantOfReservation(Map<String, dynamic>json){
    return Restaurant(
        id : json['id'],
        name: json['name'],
        address: json['address'],
        city: json['city'],
        date: null,
        phone: json['phone'],
        isSponsored: json['is_sponsored']);
  }

  static Future<Restaurant> getRestaurant(int id) async{
    //Params.setValue('token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiY2xpZW50Iiwic3ViIjoieGFwaWdlb2xldEBlcGZjLmV1IiwibmFtZSI6IlhhdmllciIsInVzZXJfaWQiOjMsImV4cCI6MTc3OTIyNTY5N30.Wx5NOHWxu7rsmkq4xbh_xvvHuCPuDdrfcg2PmQC9KuQ');
    final response = await ApiClient.get('get_restaurant?id=$id');
    if(response.statusCode == 200) {
      return Restaurant.fromJson(json.decode(response.body));
    }else{
      throw Exception('Failed to get restaurant');
    }
  }

  Future<dynamic>toggle() async{
    final response = await ApiClient.post('toggle',body: json.encode({'resto_id' : id}));
    print(response.body);
    if(response.statusCode == 200){
      return Restaurant.fromJson(json.decode(response.body));
    }else{
      final body = json.decode(response.body);
      return body['message'];
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

  static Future<int> getRestaurantCapacity(int restaurant_id) async {
    try {
      final response = await ApiClient.get('get_restaurant_capacity?restaurant_id=$restaurant_id');
      if (response.statusCode == 200){
        final body = json.decode(response.body);
        return body['restaurant_capacity'];
      } else {
        throw Exception('Failed to get restaurant capacity from DB.\nResponse: ${response.body}');
      }
    } catch(e, st){
      print('$e\n$st');
      throw Exception('Failed to get restaurant capacity.');
    }
  }

  void deleteService(Service service) {
   services!.removeWhere((serviceToDelete) => serviceToDelete.id == service.id);
  }
}