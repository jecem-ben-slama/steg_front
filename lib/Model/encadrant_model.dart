// lib/Model/encadrant_model.dart
import 'package:equatable/equatable.dart';

class Encadrant extends Equatable {
  final int? encadrantID;
  final String name;
  final String lastname;
  final String? email;

  const Encadrant({
    this.encadrantID,
    required this.name,
    required this.lastname,
    this.email,
  });

  factory Encadrant.fromJson(Map<String, dynamic> json) {
    return Encadrant(
      // Ensure 'encadrantID' is parsed correctly (it might come as string from PHP's json_encode)
      encadrantID: int.tryParse(json['encadrantID']?.toString() ?? ''),
      name: json['name'] as String,
      lastname: json['lastname'] as String,
      email: json['email'] as String?, // Nullable
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'lastname': lastname,
      'email': email, // Send null if it's null, PHP will handle it
    };
    if (encadrantID != null) {
      data['encadrantID'] = encadrantID;
    }
    return data;
  }

  Encadrant copyWith({
    int? encadrantID,
    String? name,
    String? lastname,
    String? email,
  }) {
    return Encadrant(
      encadrantID: encadrantID ?? this.encadrantID,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [encadrantID, name, lastname, email];
}
