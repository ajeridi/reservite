
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
  final Client client;
  final Restaurant? restaurant;
  final DateTime datetime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;
  final List<Table> tables;

// constructeur
  const Reservation({
    required this.id,
    required this.client,
    required this.restaurant,
    required this.datetime,
    this.numberOfGuests = 0,
    this.status = Status.pending,
    this.specialRequests = null,
    required this.tables,
});

  //constructeur from Json
  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
        id: json['id'],
        client: Client.fromJson(json['client']),
        restaurant: Restaurant.makeRestaurantOfReservation(json['restaurant']),
        datetime: DateTime.parse(json['datetime']),
        numberOfGuests: json['number_of_guests'],
        status: toStatus(json['status']),
        specialRequests: json['special_requests'],
        tables: Table.tablesFromJson(json['tables']),
    );
  }

  static Future<Reservation?> getReservation(int id) async {
    try {
      final response = await ApiClient.get("get_reservation?reservation_id=$id");
      if (response.statusCode == 200){
        final body = json.decode(response.body);
        return Reservation.fromJson(body);
      }
    } catch (e, st){
      print('$e\n$st');
      throw Exception('Failed to get reservation.');
    }

  }

  // methode qui va rechercher les reservations d'un client (Future, car on va chercher dans la DB)
  static Future<List<Reservation>> getReservations({int? selectedRestaurant = null}) async{
    String enpoint = 'get_reservations';
    if (selectedRestaurant != null) enpoint += '?restaurant_id=$selectedRestaurant';
    final response = await ApiClient.get(enpoint);
    if (response.statusCode == 200){
      // un user qui n'a pas de reservations, a un response.body == 'null'
      if (response.body == 'null') return <Reservation>[]; // on retourne liste vide si null
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

 Reservation copyWith( {
   int? id,
   Client? client,
   Restaurant? restaurant,
   DateTime? datetime,
   int? numberOfGuests,
   Status? status,
    String? specialRequests,
   List<Table>? tables}){
    return Reservation(
        id: id ?? this.id,
        client: client ?? this.client,
        restaurant: restaurant ?? this.restaurant,
        datetime: datetime ?? this.datetime,
        numberOfGuests: numberOfGuests ?? this.numberOfGuests,
        status: status ?? this.status,
        tables: tables ?? this.tables);
 }



  //recup reservation pour cancel

  Future<Reservation> getCancel() async{
    try {
      final response = await ApiClient.post(
        'cancel_reservation',
      body: json.encode({'reservation_id': id}));
      if (response.statusCode == 200) {
        return Reservation.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get reservation');
      }
    }catch(e,st){
      print(e);
      throw Exception('Failed to get user');
    }

  }

  String statusToString(){
    return switch(this.status){
      Status.pending => 'En attente',
      Status.confirmed => 'Confirmee',
      Status.completed => 'Terminee',
      Status.cancelled => 'Annulee',
    };
  }

  bool canEdit() {
    return this.status != Status.completed && this.status != Status.cancelled;
  }



  @override
  String toString() {
    return'$id $client $restaurant $datetime $numberOfGuests $status $tables';
  }
}
