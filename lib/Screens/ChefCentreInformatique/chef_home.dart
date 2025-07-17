// lib/Screens/ChefCentreInformatique/chef_centre_informatique_home.dart
import 'package:flutter/material.dart';

class ChefCentreInformatiqueHome extends StatelessWidget {
  const ChefCentreInformatiqueHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chef Centre Informatique Home')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, Chef Centre Informatique!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // You can add more widgets here, e.g., a button to navigate
            // ElevatedButton(
            //   onPressed: () {
            //     // Example navigation to another page specific to this role
            //     // context.go('/chefcentreinfo/settings');
            //   },
            //   child: const Text('Go to Settings'),
            // ),
          ],
        ),
      ),
    );
  }
}
