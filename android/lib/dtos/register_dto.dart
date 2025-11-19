class RegisterDto {
  final String password;
  final String retypePassword;
  final String fullName;
  final String phoneNumber;

  RegisterDto({
    required this.phoneNumber,
    required this.password,
    required this.retypePassword,
    required this.fullName,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'password': password,
      'retypePassword': retypePassword,
      'fullName': fullName,
    };
  }
}
