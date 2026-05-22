
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:prbd_2526_a07/core/services/api_client.dart';
import 'package:prbd_2526_a07/models/restaurant.dart';
import 'package:prbd_2526_a07/models/table.dart';

import 'client.dart';

// enum pour le statut, ne peut etre declaré dans une classe
enum Status {
  pending,
  confirmed,
  completed,
  cancelled
}

class Reservation {
  final int id;
  final int client_id; // pour la liste des reservations pour un client
  final String client_name; // pour la liste des reservations pour un manager
  final Restaurant restaurant;
  final DateTime datetime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;
  //final List<Table> tables;

// constructeur
  const Reservation({
    required this.id,
    this.client_id = 0,
    this.client_name = '',
    required this.restaurant,
    required this.datetime,
    this.numberOfGuests = 0,
    this.status = Status.pending,
    this.specialRequests = null,
});

  //constructeur from Json
  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
        id: json['id'],
        client_id: json['client'] is int ? json['client'] : 0,
        client_name: json['client'] is int ? '' : json['client'],
        restaurant: Restaurant.makeRestaurantOfReservation(json['restaurant']),
        datetime: DateTime.parse(json['datetime']),
        numberOfGuests: json['number_of_guests'],
        status: toStatus(json['status']),
    );
  }

  // methode qui va rechercher les reservations d'un client (Future, car on va chercher dans la DB)
  static Future<List<Reservation>> getReservations({int? selectedRestaurant = null}) async{
    String enpoint = 'get_reservations';
    if (selectedRestaurant != null) enpoint += '?restaurant_id=$selectedRestaurant';
    final response = await ApiClient.get(enpoint);
    if (response.statusCode == 200){
      final List<dynamic> body = json.decode(response.body); // decodage de la reponse en liste d'objet JSON [[id: 1, name:],[id: 2, name: ..]]
      return body.map((dynamic reservation) => Reservation.fromJson(reservation)).toList(); // mappage de chaque element de la liste d'objets Json en objet Reservation
    }
    else {
      throw Exception("Failed to fetch reservations from the database");
    }
  }

  // prends un status en string et le convertit en enum Status
  static Status toStatus(String statusString) {
    return switch(statusString){
      "pending" => Status.pending,
      "confirmed" => Status.confirmed,
      "completed" => Status.completed,
      "cancelled" => Status.cancelled,
      _ => throw Exception('incorrect status'),
    };
  }


  @override
  String toString() {
    return'$id $client_id $client_name  $restaurant $datetime $numberOfGuests $status';
  }
}
