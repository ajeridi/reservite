
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
  final Client client;
  final Restaurant restaurant;
  final String datetime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;
  final Set<Table> tables;

// constructeur
  const Reservation({
    required this.id,
    required this.client,
    required this.restaurant,
    required this.datetime,
    this.numberOfGuests = 0,
    this.status = Status.pending,
    this.specialRequests = null,
    required this.tables
});

  //constructeur from Json
  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
        id: json['id'],
        client: Client.fromJson(json['client']),
        restaurant: Restaurant.fromJson(json['restaurant']),
        datetime: json['datetime'],
        tables: Table.tablesFromJson(json['tables']),
    );
  }

  // methode qui va rechercher les reservations d'un client (Future, car on va chercher dans la DB)
  static Future<List<Reservation>?> getReservations() async{
    return null;
  }

}