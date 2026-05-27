

import 'dart:collection';

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
}