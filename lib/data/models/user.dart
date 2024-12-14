import 'dart:ui';

class User {
  int id;
  String email;
  String username;
  String? name;
  String jwt;
  Image? profileImage;
bool isAuthorized;
  User({
    required this.id,
    required this.email,
    required this.username,
    required this.isAuthorized,
    this.name,
    required this.jwt,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      isAuthorized: true,
      id: json['id'] ?? 0,
      email: json['email'] ?? "",
      username: json['username'] ?? "",
      name: json['name'],
      jwt: json['jwt'] ?? "",
      profileImage: null, // Если изображения нет в JSON
    );
  }
}
