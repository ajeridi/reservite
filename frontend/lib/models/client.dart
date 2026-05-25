class Client {
  final int id;
  final String name;
  final String email;
  final String phone;

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
}