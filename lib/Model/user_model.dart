import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int?
  userID; 
  final String username;
  final String? password; 
  final String email;
  final String lastname;
  final String
  role; 

  const User({
    this.userID,
    required this.username,
    this.password, 
    required this.email,
    required this.lastname,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: int.tryParse(
        json['userID'].toString(),
      ), 
      username: json['username'] as String,
      
      
      password:
          json['password'] as String?,
      email: json['email'] as String,
      lastname: json['lastname'] as String,
      role: json['role'] as String,
    );
  }

  
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'lastname': lastname,
      'role': role,
    };
    if (userID != null) {
      data['userID'] = userID;
    }
    if (password != null && password!.isNotEmpty) {
      // Only send password if it's explicitly set
      data['password'] = password;
    }
    return data;
  }

  
  User copyWith({
    int? userID,
    String? username,
    String? password,
    String? email,
    String? lastname,
    String? role,
  }) {
    return User(
      userID: userID ?? this.userID,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      lastname: lastname ?? this.lastname,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [userID, username, email, lastname, role]; 
}
