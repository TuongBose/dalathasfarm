import 'package:android/models/role.dart';

class UserResponse{
  final int id;
  final DateTime dateOfBirth;
  final String? address;
  final String phoneNumber;
  final bool isActive;
  final String fullName;
  final String? email;
  final Role role;

  UserResponse({
    required this.id,
    required this.fullName,
    this.email,
    required this.phoneNumber,
    this.address,
    required this.dateOfBirth,
    required this.role,
    required this.isActive,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      role: Role.fromJson(json['role']),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'role': role.toJson(),
      'isActive': isActive,
    };
  }
}