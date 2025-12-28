class ChangePasswordDto{
  final String oldPassword;
  final String newPassword;
  final String retypeNewPassword;

  ChangePasswordDto({
    required this.oldPassword,
    required this.newPassword,
    required this.retypeNewPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'retypeNewPassword': retypeNewPassword,
    };
  }
}