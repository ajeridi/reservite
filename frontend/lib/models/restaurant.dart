class Restaurant {
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;

  // constructeur
  const Restaurant({
    this.id = 0,
    this.name = '',
    this.address = '',
    this.city = '',
    this.phone = '',
  });

  // constructeur Json
  factory Restaurant.fromJson(Map<String, dynamic> json){
    return Restaurant(
      id: json['id'],
      name: json['name'],
      city: json['city'],
    );
  }
}