import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/services/api_client.dart';

class Table {
  final int id;
  final int ?restaurant;
  final int tableNumber;
  final int capacity;

  //constructeur
  const Table({
    this.id = 0,
    this.restaurant = 0,
    this.tableNumber = 0,
    this.capacity = 0,
});

  // constructeur from Json
  factory Table.fromJson(Map<String, dynamic> json){
    return Table(
      id: json['id'] ?? 0,
      restaurant: json['restaurant'] ?? 0,
      tableNumber: json['table_number'] ?? 0,
      capacity: json['capacity'] ?? 0,
    );
  }

  // prends une collection Json table et retourne un SET de tables
  static List<Table> tablesFromJson(List<dynamic>? json) {
    List<Table> tables = []; // infos, https://dart.dev/language/collections#sets
    if (json == null)
      return tables;
    for (Map<String, dynamic> tableJson in json) {
      Table table = Table.fromJson(tableJson);
      tables.add(table);
    }
    return tables;
  }

  // methode qui va rechercher les tables d'un restaurant (Future, car on va chercher dans la DB)
  static Future<List<Table>> getTables({int? selectedRestaurant = null}) async{
    String enpoint = 'get_tables';
    if (selectedRestaurant != null) enpoint += '?restaurant_id=$selectedRestaurant';
    final response = await ApiClient.get(enpoint);
    if (response.statusCode == 200){
      // un user qui n'a pas de tables, a un response.body == 'null'
      if (response.body == 'null') return <Table>[]; // on retourne liste vide si null
      final List<dynamic> body = json.decode(response.body); // decodage de la reponse en liste d'objet JSON [[id: 1, name:],[id: 2, name: ..]]
      return body.map((dynamic table) => Table.fromJson(table)).toList(); // mappage de chaque element de la liste d'objets Json en objet Table
    }
    else {
      throw Exception("Failed to fetch tables from the database");
    }
  }

  static Future<Table?> getTable(int id) async {
    try {
      final response = await ApiClient.get("get_table?reservation_id=$id");
      if (response.statusCode == 200){
        final body = json.decode(response.body);
        return Table.fromJson(body);
      }
    } catch (e, st){
      print('$e\n$st');
      throw Exception('Failed to get reservation.');
    }

  }
}