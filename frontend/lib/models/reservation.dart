
import 'dart:convert';

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
  final int client;
  final Restaurant restaurant;
  final DateTime datetime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;
  //final List<Table> tables;

// constructeur
  const Reservation({
    required this.id,
    required this.client,
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
        client: json['client'],
        restaurant: Restaurant.fromJson(json['restaurant']),
        datetime: DateTime.parse(json['datetime']),
        numberOfGuests: json['number_of_guests'],
        status: toStatus(json['status']),
    );
  }

  // methode qui va rechercher les reservations d'un client (Future, car on va chercher dans la DB)
  static Future<List<Reservation>> getReservations() async{
    final response = await ApiClient.get("get_reservations");
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
    return'$id $client $restaurant $datetime $numberOfGuests $status';
  }
}
