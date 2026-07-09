class LoginModel {
  final String id;
  final String email;
  final String password;

  const LoginModel({
    required this.id,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'email': this.email,
      'password': this.password,
    };
  }

  factory LoginModel.fromMap(Map<String, dynamic> map) {
    return LoginModel(
      id: map['id'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }}