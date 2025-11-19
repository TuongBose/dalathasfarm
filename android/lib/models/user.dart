import 'package:android/models/role.dart';

class User{
  final int id;
  final String fullName;
  final String address;
  final String phoneNumber;
  final DateTime dateOfBirth;
  final String email;
  final String profileImage;
  final Role roleName;
  final bool active;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.dateOfBirth,
    required this.profileImage,
    required this.roleName,
    required this.active,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      profileImage: json['profileImage'],
      roleName: Role.fromJson(json['roleName']),
      active: json['active'],
    );
  }
}