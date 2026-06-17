

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

  // methode qui va rechercher les tables d'un restaurant (Future, car on va chercher dans la DB)
  static Future<Map<String, SplayTreeSet<Services>>> getServices({int? selectedRestaurant = null}) async{
    String enpoint = 'get_services';
    
    Map<String, SplayTreeSet<Services>> services = new HashMap();
    if (selectedRestaurant != null) enpoint += '?restaurant_id=$selectedRestaurant';
    final response = await ApiClient.get(enpoint);
    if (response.statusCode == 200){
      // un user qui n'a pas de services, a un response.body == 'null'
      if (response.body == 'null') {
        return <String, SplayTreeSet<Services>>{}; // on retourne map vide si null

      }final List<dynamic> body = json.decode(response.body); // decodage de la reponse en liste d'objet JSON [[id: 1, name:],[id: 2, name: ..]]
      
      for(var serviceJson in body) {
        String jour = getJour(serviceJson['day_of_week']);
        services.putIfAbsent(jour, SplayTreeSet<Services>());

        DateTime debut = serviceJson['start_time'];
        DateTime fin = serviceJson['end_time'];

        services[jour]?.add(new Services(id: serviceJson['id'], resto: serviceJson['restaurant'], dayOfWeek: serviceJson['day_of_week'], startTime: serviceJson['start_time'], endTime: serviceJson['end_time']));

      }
    }
    else {
      throw Exception("Failed to fetch services from the database.\nResponse body: ${response.body}");
    }
  }

  static Future<Services?> getService(int serviceId, int restaurantId) async {
    try {
      final response = await ApiClient.get("get_service?service_id=$serviceId&restaurant_id=$restaurantId");
      if (response.statusCode == 200){
        final body = json.decode(response.body);
        return Services.fromJson(body);
      }
    } catch (e, st){
      print('$e\n$st');
      throw Exception('Failed to get service.');
    }

  }

  static Future<Services> save_service(int? newServiceDay, int newHeureDebut, int newHeureFin, int serviceId, int restaurantId) async {
    final response = await ApiClient.post('save_service',
        body: json.encode({
          'service_id' : serviceId,
          'new_service_day' : newServiceDay,
          'new_heure_debut' : newHeureDebut,
          'new_heure_fin'   : newHeureFin,
          'restaurant_id' : restaurantId
        })
    );

    print('${response.body}');
    if (response.statusCode == 200 ){
      final body = json.decode(response.body);
      return Services.fromJson(body);
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
  int compareTo(Services other) {
    // TODO: implement compareTo
    if(this.dayOfWeek - other.dayOfWeek == 0)
      return this.startTime.hour - other.startTime.hour;
    return this.dayOfWeek - other.dayOfWeek;
  }
}