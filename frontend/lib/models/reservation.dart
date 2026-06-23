
import 'dart:collection';
import 'dart:convert';



import 'package:intl/intl.dart';
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

class Reservation  implements Comparable<Reservation>{
  final int id;
  final Client client;
  final Restaurant? restaurant;
  final DateTime datetime;
  final int numberOfGuests;
  final Status status;
  final String? specialRequests;
  final bool isVip;
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
    required this.isVip,
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
        isVip: json['is_vip'],
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
  static Future<SplayTreeSet<Reservation>> getReservations({int? selectedRestaurant = null}) async{
    String enpoint = 'get_reservations';
    if (selectedRestaurant != null) enpoint += '?restaurant_id=$selectedRestaurant';
    final response = await ApiClient.get(enpoint);
    if (response.statusCode == 200){
      // un user qui n'a pas de reservations, a un response.body == 'null'
      if (response.body == 'null') return SplayTreeSet<Reservation>(); // on retourne liste vide si null
      final List<dynamic> body = json.decode(response.body); // decodage de la reponse en liste d'objet JSON [[id: 1, name:],[id: 2, name: ..]]
      return SplayTreeSet.of(body.map((dynamic reservation) => Reservation.fromJson(reservation)).toList()); // mappage de chaque element de la liste d'objets Json en objet Reservation
    }
    else {
      print(response.body);
      throw Exception("Failed to fetch reservations from the database");
    }
  }

  static Future<Reservation?> confirmReservation({
    required int reservationId,
    required List<int> tablesId,
  }) async {
    final response = await ApiClient.post('confirm_reservation',
      body: json.encode({
        'reservation_id': reservationId,
        'tables_id' : tablesId,
      }),
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return Reservation.fromJson(body);
    } else {
      throw Exception('Failed to confirm reservation: ${response.body}');
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
   bool? isVip,
   List<Table>? tables}){
    return Reservation(
        id: id ?? this.id,
        client: client ?? this.client,
        restaurant: restaurant ?? this.restaurant,
        datetime: datetime ?? this.datetime,
        numberOfGuests: numberOfGuests ?? this.numberOfGuests,
        status: status ?? this.status,
        isVip: isVip ?? this.isVip,
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
      throw Exception('Failed to change reservation status to Canceled');
    }

  }

  // recup reservation pour complete reservation

  Future<Reservation> getCompleted() async{
    try{
      final response = await ApiClient.post(
        'complete_reservation',
        body:json.encode({'reservation_id' : id})
      );
      if(response.statusCode == 200){
        return Reservation.fromJson(json.decode(response.body));
      }else{
        throw Exception('Failed to get reservation');
      }
    }catch(e){
      print(e);
      throw Exception('Failed to change reservation status to Completed');
    }
  }

  Future<dynamic>toggle() async{
    try{
      final response = await ApiClient.post('toggle',
        body: json.encode({'reservation_id' : id})
      );
      print(response.body);
      if(response.statusCode == 200){
        return Reservation.fromJson(json.decode(response.body));
      }else{
        final body = json.decode(response.body);
        return body['message'];
      }
    }catch(e){

      throw Exception('Failed to toggle isVIP reservation exception in catch.');
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


  static Future<DateTime> getFirstAvailableReservationDateTime() async {
    try {
      final response = await ApiClient.get("get_first_available_reservation_datetime");
      if (response.statusCode == 200){
        final body = json.decode(response.body);
        return body['first_available_reservation_datetime'];
      }
      throw Exception('Failed to get first available reservation datetime\nResponse code : ${response.statusCode}');
    } catch (e, st){
      throw Exception("Failed to get first available reservation datetime.");
    }
  }

  @override
  String toString() {
    return'$id $client $restaurant $datetime $numberOfGuests $status $tables';
  }

  static Future<bool> checkCapacity({required int restaurantId, required DateTime date, required String slot, required int numberOfGuests, required int reservation_id}) async {
      final dateString = DateFormat('yyyy-MM-dd', 'fr_FR').format(date);
      try {
        final response = await ApiClient.get('check_number_of_guests_validity?restaurant_id=$restaurantId&selected_date=$dateString&time_slot=$slot&_number_of_guests=$numberOfGuests&reservation_id=$reservation_id');
        if (response.statusCode != 200) {
          throw Exception('Failed to check capacity.\nStatus Code: ${response.statusCode}');
        }
        final body = json.decode(response.body);
        return body;

      } catch (e, st) {
        print('$e\n$st');
        throw Exception('Failed to check capacity.');
      }
    }

  static Future<Reservation> saveReservation({required int restaurantId, required DateTime date, required String slot, required int numberOfGuests, String? specialRequests, required int? reservationId}) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      final parts = slot.split(':');

      final reservationDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      final datetimeString =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(reservationDateTime);

      final response = await ApiClient.post(
        'save_reservation',
        body: json.encode({
          'restaurant_id': restaurantId,
          'datetime_': datetimeString,
          'number_of_guests_': numberOfGuests,
          'special_requests_': specialRequests,
          'reservation_id' : reservationId,
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return Reservation.fromJson(body);
      }
      throw Exception(
        'Failed to save reservation. Status code: ${response.statusCode}\nBody: ${response.body}',
      );
    } catch (e, st) {
      print('$e\n$st');
      throw Exception('Failed to save reservation.');
    }
  }

  @override
  int compareTo(Reservation other) {
    // TODO: implement compareTo
    return this.datetime.compareTo(other.datetime) == 0 ? other.id.compareTo(this.id) : other.datetime.compareTo(this.datetime);
  }

  static String? validateSpecialRequests(String? newSpecialRequests){
    final text = newSpecialRequests?.trim() ?? '';

    if (text.isEmpty) {
      return null;
    }

    if (text.length < 10) {
      return 'La demande spéciale doit contenir au moins 10 caractères.';
    }
    return null;
  }
}
