

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/src/material/time.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/core/tools/datetime_utils.dart';
import 'package:prbd_2526_a07/models/services.dart';

import '../core/services/api_client.dart';

class Service implements Comparable<Service>{

final int id;
final int resto;
final int dayOfWeek;
final DateTime startTime;
final DateTime endTime;
final bool? isUsed;

const Service({
  required this.id,
  required this.resto,
  required this.dayOfWeek,
  required this.startTime,
  required this.endTime,
  this.isUsed = false
});

//constructeur Json , on fait un parse du string reçu en json en DateTime
  factory Service.fromJson(Map<String, dynamic> json){
    return Service(id: json['id'],
        resto: json['restaurant'],
        dayOfWeek: json['day_of_week'],
        startTime:DateTime.parse('2012-02-27 ${json['start_time']}'),
        endTime: DateTime.parse('2012-02-27 ${json['end_time']}'),
        isUsed: json['is_used']
    );
  }

  //
  static SplayTreeSet<Service> servicesFromJson (List<dynamic> json){
    var services= SplayTreeSet<Service>();
    for(var serv in json){
      services.add(Service.fromJson(serv));
    }
    return services;
  }

  // methode qui va rechercher les tables d'un restaurant (Future, car on va chercher dans la DB)
  static Future<SplayTreeMap<int, Services>> getServices({int? selectedRestaurant = null}) async{
    String enpoint = 'get_services';
    
    SplayTreeMap<int, Services> servicesByDayOfWeek = new SplayTreeMap();
    if (selectedRestaurant != null) enpoint += '?restaurant_id=$selectedRestaurant';
    final response = await ApiClient.get(enpoint);
    if (response.statusCode == 200){
      // un user qui n'a pas de services, a un response.body == 'null'
      if (response.body == 'null') {
        return SplayTreeMap(); // on retourne map vide si null
      }
      final List<dynamic> body = json.decode(response.body); // decodage de la reponse en liste d'objet JSON [[id: 1, name:],[id: 2, name: ..]]
      createServicesPerDayOfWeek(body, servicesByDayOfWeek);
      return servicesByDayOfWeek;
    }
    else {
      throw Exception("Failed to fetch services from the database.\nResponse body: ${response.body}");
    }
  }

  static void createServicesPerDayOfWeek(List<dynamic> body, Map<int, Services> servicesByDayOfWeek) {
    for(var serviceJson in body) {
      int dow = serviceJson['day_of_week'];
      Service newService = Service.fromJson(serviceJson);
      // avant d'ajouter le service dans le TreeSet au jour, on doit verifier si le tree set existe, sinon on ajoute un TreeSet vide
      if (servicesByDayOfWeek[dow] == null) {servicesByDayOfWeek[dow] = Services([newService]);}
      // sinon on ajoute simplement le service dans le tree set
      else {servicesByDayOfWeek[dow]!.add(newService);}
    }
    // ensuite il faut rajouer les jours sans services, car getServices ne retourne que les jours contenant un ou plusieurs services
    addDaysWithoutServices(servicesByDayOfWeek);
  }

  static Future<Service?> getService(int serviceId, int restaurantId) async {
    try {
      final response = await ApiClient.get("get_service?service_id=$serviceId&restaurant_id=$restaurantId");
      if (response.statusCode == 200){
        final body = json.decode(response.body);
        return Service.fromJson(body);
      }
    } catch (e, st){
      print('$e\n$st');
      throw Exception('Failed to get service.');
    }

  }

  static Future<Service> save_service(int? newServiceDay, TimeOfDay newHeureDebut, TimeOfDay newHeureFin, int serviceId, int restaurantId) async {
    final response = await ApiClient.post('save_service',
        body: json.encode({
          'service_id' : serviceId,
          'new_service_day' : newServiceDay,
          'new_heure_debut' : '${newHeureDebut.hour}:${newHeureDebut.minute}:00',
          'new_heure_fin'   : '${newHeureFin.hour}:${newHeureFin.minute}:00',
          'restaurant_id' : restaurantId
        })
    );

    print('${response.body}');
    if (response.statusCode == 200 ){
      final body = json.decode(response.body);
      return Service.fromJson(body);
    }
    else{
      throw Exception("Failed to save service");
    }
  }

  static String getJour(int day_of_week) {
    if (day_of_week == 1)
      return 'Lundi';
    if (day_of_week == 2)
      return 'Mardi';
    if (day_of_week == 3)
      return 'Mercredi';
    if (day_of_week == 4)
      return 'Jeudi';
    if (day_of_week == 5)
      return 'Vendredi';
    if (day_of_week == 6)
      return 'Samedi';
    if (day_of_week == 7)
      return 'Dimanche';

    return '';
  }

  // on compare en fonction du jour de la semaine
  @override
  int compareTo(Service other) {
    // TODO: implement compareTo
    if(this.dayOfWeek - other.dayOfWeek == 0)
      return this.startTime.hour - other.startTime.hour;
    return this.dayOfWeek - other.dayOfWeek;
  }

  static void addDaysWithoutServices(Map<int, Services> servicesByDayOfWeek) {
    //  pour chaque jour de la semaine, on regarde s'il existe dans la map de services, sinon on ajoute le jour avec un set vide de services
    for (int dow = 1; dow <= 7; ++dow){
      if (!servicesByDayOfWeek.containsKey(dow)){
        servicesByDayOfWeek[dow] = Services([]);
      }
    }
  }

  // retourne un string avec start et end time sous format "HH:mm - HH:mm"
  startEndTimeString() {
    String startTimeFormatted = DateFormat("HH:mm", "fr_FR").format(startTime);
    String endTimeFormatted = DateFormat("HH:mm", "fr_FR").format(endTime);
    return '$startTimeFormatted - $endTimeFormatted';
  }

  Future<bool> delete() async {
    try {
      final response = await ApiClient.post(
        'delete_service',
        body: json.encode({
          'service_id': this.id
        }),
      );
      if (response.statusCode == 204) {
        return true;
      }
      throw Exception('Service deletion unsuccessful. \nBody: ${response.body}');
    } catch (e, st) {
      throw Exception('$e\n$st');
    }
  }

  static Future<String?> asyncValidateService(int restaurantId, int serviceId, String dayOfWeek, TimeOfDay startTime, TimeOfDay endTime) async {
    // verifier si le service chevauche avec d'autre services du meme jour
    // verifier, si le service existe, si des reservations se trouvent en dehors du nouveau creneau
    try {
      int dow = DatetimeUtils.stringToDow(dayOfWeek);
      final startTimeString = '${startTime.hour}:${startTime.minute}:00';
      final endTimeString = '${endTime.hour}:${endTime.minute}:00';
      print('validate_service?_restaurant_id=$restaurantId&_service_id=$serviceId&_dow=$dow&_start_time=$startTimeString&_end_time=$endTimeString');
      final response = await ApiClient.get('validate_service?_restaurant_id=$restaurantId&_service_id=$serviceId&_dow=$dow&_start_time=$startTimeString&_end_time=$endTimeString');
      print(response.body);
      if (response.statusCode == 200){
        final body = json.decode(response.body);
        return body['error'];
      }
      return null;
    }catch(e, st){
      throw Exception('$e\n$st');
    }
  }
}