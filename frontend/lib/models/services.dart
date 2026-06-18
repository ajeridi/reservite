

import 'dart:collection';
import 'dart:convert';

import 'package:prbd_2526_a07/core/services/api_client.dart';

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

  //checher la liste de services d'un restaurant(Future-> dans la DB)
  static Future<SplayTreeSet<Services>> getServices({int? selectedRestaurant = null}) async{
    String endpoint = 'get_services_par_restaurant';
    if(selectedRestaurant != null) {
      endpoint +='?restaurant_id=$selectedRestaurant';
    }
    final response = await ApiClient.get(endpoint);
    if(response.statusCode == 200){
      //si le resto n'a pas de services, response.body =='null'
      if(response.body == 'null') return SplayTreeSet<Services>(); //retourne liste vide
      final List<dynamic> body = json.decode(response.body);
      return SplayTreeSet.of(body.map((dynamic service) => Services.fromJson(service)).toList());
    }
    else{
      throw Exception("Failed to fetch tables from DB?\n Response.body= ${response.body}");
    }
  }

  static Future<Services> getService(int serviceId, int restaurantId) async{
    try{
      final response = await ApiClient.get("get_service_par_restaurant?service_id=$serviceId&restaurant_id=$restaurantId");
      if(response.statusCode == 200){
        final body = json.decode(response.body);
        return Services.fromJson(body);
      }else{
        throw Exception('Failed to get the service for the restaurant');
      }
    }catch(e){
      print(e);
      throw Exception('Failed to get the service for the restaurant');
    }
  }

  static Future<bool?> is_not_empty({required int idservice, required DateTime reservation_datetime}) async {
    try {
      final response = await ApiClient.get("is_nut_empty?id_service=$idservice&reservation_datetime=$reservation_datetime");

      if (response.statusCode == 200){
        return json.decode(response.body) as bool;
      }

    } catch (e, st){
      print('$e\n$st');
      throw Exception('Failed to get is_not_empty from services endpoint');
    }
  }

  // on compare en fonction du jour de la semaine
  @override
  int compareTo(Services other) {
    // TODO: implement compareTo
    if(this.dayOfWeek - other.dayOfWeek == 0)
      return this.startTime.hour - other.startTime.hour;
    return this.dayOfWeek - other.dayOfWeek;
  }
}