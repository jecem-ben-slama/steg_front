
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int?
  userID; // Nullable for new users (before ID is assigned by backend)
  final String username;
  final String? password; // Password can be null for updates if not changing
  final String email;
  final String lastname;
  final String
  role; // e.g., 'Gestionnaire', 'Encadrant', 'ChefCentreInformation'

  const User({
    this.userID,
    required this.username,
    this.password, // Made nullable for convenience in updates, but required for creation
    required this.email,
    required this.lastname,
    required this.role,
  });

  // Factory constructor to create a User from JSON (e.g., from API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: int.tryParse(
        json['userID'].toString(),
      ), // Handle potential string ID from DB
      username: json['username'] as String,
      // password is not usually returned in GET requests for security
      // We might add it if a specific API endpoint returns it securely (e.g., for direct login).
      // For general list/edit, it's typically omitted.
      password:
          json['password'] as String?, // If your backend sometimes returns it
      email: json['email'] as String,
      lastname: json['lastname'] as String,
      role: json['role'] as String,
    );
  }

  // Method to convert User to JSON (e.g., for sending to API)
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

  // Method to create a copy with updated fields (useful for editing)
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
  List<Object?> get props => [userID, username, email, lastname, role]; // Password excluded for equality check
}
