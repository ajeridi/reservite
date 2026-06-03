import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_a07/core/services/api_client.dart';

class AvailableSlots{
  final List<String>? slots; // va contenir les creneaux
  final String? error; // va contenir le message d'erreur si pas  de creneaux

  const AvailableSlots({this.slots, this.error});

  factory AvailableSlots.fromJson(Map<String, dynamic>json){
    return AvailableSlots(
      slots: toStringList(json['slots']),
      error: json['message'],
    );
  }

  static Future<AvailableSlots> getAvailableSlots(int restaurantId, DateTime date) async {
      final dateString =  DateFormat('yyyy-MM-dd', 'fr_FR').format(date);
      try{
        final response = await ApiClient.get("get_available_slots?restaurant_id=${restaurantId}&date_of_reservation=$dateString");
        if (response.statusCode != 200){
          throw Exception("Failed to get available slots from database.\nStatus Code: ${response.statusCode}");
        }
        final body = json.decode(response.body);
        return AvailableSlots.fromJson(body);
      }catch(e, st){
        debugPrint('$e\n$st');
        throw Exception('Failed to get available slots from database');
      }
  }

  @override
  String toString() {
    return '{slots: $slots, error: $error}';
  }

  static List<String>? toStringList(List<dynamic> slotsList) {
    final newList = <String>[];
    if (slotsList == null)
      return newList;
    for (String elem in slotsList){
        newList.add(elem);
    }
    return newList;
  }
}