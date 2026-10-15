import 'dart:convert';

import 'package:prbd_2526_a07/core/services/api_client.dart';

class Client {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role = 'client';

  // constructeur Client avec valeurs par défaut
  const Client({
    this.id = 0,
    this.name = '',
    this.email = '',
    this.phone = '',
  });


  // constructeur de client à partir d'un JSON
  factory Client.fromJson(Map<String, dynamic> json){
    return Client(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  static Future<Client> getConnectedClient() async{
    final response = await ApiClient.get("get_connected_client");
    try {
      if (response.statusCode != 200) {
        throw Exception("Failure to get client");
      }
      final body = json.decode(response.body);
      return Client.fromJson(body);
    } catch (e, st){
      print('$e\n$st');
      throw Exception('Something went wrong.\nPlease try again later');
    }
  }

  @override
  String toString() {
    return "{id: $id, name: $name, email: $email, phone: $phone}";
  }
}