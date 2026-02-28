class User {
  final int id;
  final String? email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? city;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.city,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 01,
      email: json['email'] ?? 'Guest@gmail.com',
      username: json['username'] ?? 'Guest_uid',
      firstName: json['name']['firstname'] ?? 'Guest_FirstName',
      lastName: json['name']['lastname'] ?? 'Guest_LastName',
      phone: json['phone'] ?? '+88017xxxxxxxx',
      city: json['address']['city'] ?? 'Chittagong',
    );
  }
}
