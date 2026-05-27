import 'package:flutter/material.dart';

class Table {
  final int id;
  final int tableNumber;
  final int capacity;

  //constructeur
  const Table({
    this.id = 0,
    this.tableNumber = 0,
    this.capacity = 0,
});

  // constructeur from Json
  factory Table.fromJson(Map<String, dynamic> json){
    return Table(
      id: json['id'] ?? 0,
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
}