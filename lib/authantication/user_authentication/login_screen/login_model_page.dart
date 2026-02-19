class UserLoginModel {
  String message;
  String role;
  int userId;
  String name;
  int engineerId;
  //String password;
  String email;

  UserLoginModel({
    required this.message,
    required this.role,
    required this.userId,
    required this.name,
    required this.engineerId,
    required this.email,
  });

  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    return UserLoginModel(
      //   message: json['message'],
      //   role: json['role'],
      //   userId: json['user_id'],
      //   name: json['name'],
      //  // password: json['password'],
      //   email: json['email'],
      message: json['message'] ?? '',
      role: json['role'] ?? _detectRole(json),
      userId: json['user_id'] ?? 0,
      engineerId: json['engineer_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  get status => null;

  // Map<String, dynamic> toJson() {
  //   return {'user': userType, 'email': email, 'password': password};
  // }
  static String _detectRole(Map<String, dynamic> json) {
    if (json.containsKey('engineer_id')) {
      return 'engineer';
    } else if (json.containsKey('user_id')) {
      return 'user';
    }
    return '';
  }
}
