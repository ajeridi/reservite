// Classe qui va representer la date et heure courante de l'application

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:prbd_2526_a07/core/services/api_client.dart';

class ApplicationTime {

  // methode qui va recuperer la date/heure courante de l'application
  static Future<DateTime> get() async {
    try {
      final response = await ApiClient.get("get_simulated_time", anonymous: true);
      if (response.statusCode != 200){
        throw Exception("Failed to fetch simulated time.");
      }
      final body = jsonDecode(response.body);
      return DateTime.parse(body['simulated_time']);
    } catch(e, st){
      debugPrint('$e\n$st');
      throw Exception('Failed to get time');
    }


  }
}