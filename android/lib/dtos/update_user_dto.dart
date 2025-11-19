class UpdateUserDto {
  final String fullName;
  final String address;
  final String password;
  final String retypePassword;
  final String dateOfBirth;

  UpdateUserDto({
    required this.fullName,
    required this.address,
    required this.password,
    required this.retypePassword,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'address': address,
      'password': password,
      'retypePassword': retypePassword,
      'dateOfBirth': dateOfBirth,
    };
  }
}
