class LoginResponse {
  final String status;
  final String message;
  final int? userId; // Nullable if login fails
  final String? username; // Nullable if login fails
  final String? role; // Nullable if login fails
  final String? token; // Nullable if login fails

  LoginResponse({
    required this.status,
    required this.message,
    this.userId,
    this.username,
    this.role,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      userId: json['userID'] as int?,
      username: json['username'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'userID': userId,
      'username': username,
      'role': role,
      'token': token,
    };
  }
}
