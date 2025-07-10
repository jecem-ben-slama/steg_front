class User {
  final int userId;
  final String username;
  final String role;

  User({required this.userId, required this.username, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userID'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'userID': userId, 'username': username, 'role': role};
  }
}
