

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

  //recup de tous les services d'un resto
  static Future<List<Services>> getServices(int restaurant_id) async{
    try{
      final response = await ApiClient.get('get_services?restaurant_id=$restaurant_id');
      if(response.statusCode == 200){
        if(response.body == 'null') return [];
        final List<dynamic> body = json.decode(response.body);
        return body.map((s) => Services.fromJson(s)).toList();
      }
      throw Exception('Failed to get services');
    }catch(e){
      print(e);
      throw Exception('Failed to get services, Try failed');
    }
  }

  //recup service par id
  static Future<Services> getService(int service_id) async{
    try{
      final response = await ApiClient.get('get_service?service_id=$service_id');
      if(response.statusCode == 200) {
        return Services.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to get the service');
    }catch(e){
      print(e);
      throw Exception('Try failed , getService failed');
    }
  }

  //insert service si service_id Null, sinon Update
  static Future<Services> save(
      int? serviceId,
      int restaurantId,
      int dayOfWeek,
      String startTime,
      String endTime) async{
    try{
      final response = await ApiClient.post('save_service', body: json.encode(
          {'service_id' : serviceId,
          'restaurant_id': restaurantId,
          'day_of_week' : dayOfWeek,
          'start_time' : startTime,
          'end_time' : endTime}),);
      if(response.statusCode == 200){
        return Services.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to save service');
    }catch(e){
      print(e);
      throw Exception('Try failed, save service failed');
    }
  }

  // vers API : DateTime → string
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';
  }

  // delete service
  static Future<void> delete(int serviceId) async{
    try{
      final response = await ApiClient.post('delete_service', body: json.encode(
          {'service_id' : serviceId}));
      if(response.statusCode != 200){
        throw Exception('Failed to delete service');
      }
    }catch(e){
      print(e);
      throw Exception('try failed, delete service failed');
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

  //methode pour convertir le numero du jour en nom
static String dayOfWeekToString(int dayOfWeek){
    return switch (dayOfWeek){
      1 => 'Lundi',
      2 => 'Mardi',
      3 => 'Mercredi',
      4 => 'Jeudi',
      5 => 'Vendredi',
      6 => 'Samedi',
      7 => 'Dimanche',
      _ => 'Inconnu',
    };
}
}