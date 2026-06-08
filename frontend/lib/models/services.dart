

import 'dart:collection';
import 'dart:convert';

import '../core/services/api_client.dart';

class Services implements Comparable<Services>{

final int id;
final int resto;
final int dayOfWeek;
final DateTime startTime;
final DateTime endTime;

const Services({
  required this.id,
  required this.resto,
  required this.dayOfWeek,
  required this.startTime,
  required this.endTime
});

//constructeur Json , on fait un parse du string reçu en json en DateTime
  factory Services.fromJson(Map<String, dynamic> json){
    return Services(id: json['id'],
        resto: json['restaurant'],
        dayOfWeek: json['day_of_week'],
        
        startTime:DateTime.parse('2012-02-27 ${json['start_time']}'),
        endTime: DateTime.parse('2012-02-27 ${json['end_time']}'));
  }

  //
  static SplayTreeSet<Services> servicesFromJson (List<dynamic> json){
    var services= SplayTreeSet<Services>();
    for(var serv in json){
      services.add(Services.fromJson(serv));
    }
    return services;
  }

  // on compare en fonction du jour de la semaine
  @override
  int compareTo(Services other) {
    // TODO: implement compareTo
    if(this.dayOfWeek - other.dayOfWeek == 0)
      return this.startTime.hour - other.startTime.hour;
    return this.dayOfWeek - other.dayOfWeek;
  }

  // methode qui va rechercher les services d'un restaurant (Future, car on va chercher dans la DB)
  static Future<List<Services>> getServices({int? selectedRestaurant = null}) async{
    String enpoint = 'get_services';
    if (selectedRestaurant != null) enpoint += '?restaurant_id=$selectedRestaurant';
    final response = await ApiClient.get(enpoint);
    if (response.statusCode == 200){
      // un user qui n'a pas de services, a un response.body == 'null'
      if (response.body == 'null') return <Services>[]; // on retourne liste vide si null
      final List<dynamic> body = json.decode(response.body); // decodage de la reponse en liste d'objet JSON [[id: 1, name:],[id: 2, name: ..]]
      return body.map((dynamic table) => Services.fromJson(table)).toList(); // mappage de chaque element de la liste d'objets Json en objet Service
    }
    else {
      throw Exception("Failed to fetch services from the database");
    }
  }

  static Future<Services?> getService(int idservice, int idrestaurant) async {
    try {
      final response = await ApiClient.get("get_service?service_id=$idservice&restaurant_id=$idrestaurant");
      if (response.statusCode == 200){
        final body = json.decode(response.body);
        return Services.fromJson(body);
      }
    } catch (e, st){
      print('$e\n$st');
      throw Exception('Failed to get table.');
    }

  }

  static Future<bool?> is_empty({required int day_of_weekk, required int restaurantid}) async {
    try {
      final response = await ApiClient.get("isempty?day_of_weekk=$day_of_weekk&restaurantid=$restaurantid");

      if (response.statusCode == 200){
        return json.decode(response.body) as bool;
      }

    } catch (e, st){
      print('$e\n$st');
      throw Exception('Failed to get is_empty');
    }

  }

  static Future<bool?> canDelete({required int serviceId}) async {
    try {
      final response = await ApiClient.get(
        "can_delete_service?service_id=$serviceId",
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as bool;
      }
    } catch (e, st) {
      print('$e\n$st');
    }
    return null;
  }

  static Future<bool> delete({required int serviceId}) async {
    try {
      final response = await ApiClient.post(
        'delete_service',
        body: json.encode({'service_id': serviceId}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as bool;
      }
      print('delete_service failed: ${response.statusCode} ${response.body}');
    } catch (e, st) {
      print('$e\n$st');
    }
    return false;
  }

  static Future<Services> update({
    required int serviceId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final response = await ApiClient.post(
      'update_service',
      body: json.encode({
        'service_id': serviceId,
        'day_of_week_': dayOfWeek,
        'start_time_': startTime,
        'end_time_': endTime,
      }),
    );
    if (response.statusCode == 200) {
      return Services.fromJson(json.decode(response.body));
    }
    // on essaie de remonter le message d'erreur du trigger (chevauchement, alignement, ...)
    String message = 'Échec de la modification du service.';
    try {
      final body = json.decode(response.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }

  static Future<Services> create({
    required int restaurantId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final response = await ApiClient.post(
      'create_service',
      body: json.encode({
        'restaurant_id_': restaurantId,
        'day_of_week_': dayOfWeek,
        'start_time_': startTime,
        'end_time_': endTime,
      }),
    );
    if (response.statusCode == 200) {
      return Services.fromJson(json.decode(response.body));
    }
    String message = 'Échec de la création du service.';
    try {
      final body = json.decode(response.body);
      if (body is Map && body['message'] != null) {
        message = body['message'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }

  static Future<int?> countReservationsOutside({
    required int serviceId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await ApiClient.get(
        "count_reservations_outside_service?service_id=$serviceId&day_of_week_=$dayOfWeek&start_time_=$startTime&end_time_=$endTime",
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as int;
      }
    } catch (e, st) {
      print('$e\n$st');
    }
    return null;
  }

}