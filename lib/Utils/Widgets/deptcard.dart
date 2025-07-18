import 'package:flutter/material.dart';

class DeptCard extends StatelessWidget {
  final String title;
  const DeptCard({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      
      child: Container(

        width: MediaQuery.of(context).size.width * 0.11,
        height: MediaQuery.of(context).size.height * 0.1,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
