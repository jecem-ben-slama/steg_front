// lib/Screens/ChefCentreInformatique/chef_dashboard.dart
import 'package:flutter/material.dart';

class ChefDashboardScreen extends StatelessWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Chef Centre Informatique Dashboard Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// You might also have:
// lib/Screens/ChefCentreInformatique/user_management_screen.dart
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'User Management Panel for Chef',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
