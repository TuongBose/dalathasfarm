class LoginDto{
    final String password;
    final String phoneNumber;

    LoginDto({
      required this.phoneNumber,
      required this.password,
    });

    Map<String, dynamic> toJson() {
      return {
        'phoneNumber': phoneNumber,
        'password': password,
      };
    }
}