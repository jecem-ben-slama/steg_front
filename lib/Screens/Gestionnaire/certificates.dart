import 'package:flutter/material.dart';



class Certificates extends StatelessWidget {
  const Certificates({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Papers Management Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}


class SupervisorsView extends StatelessWidget {
  const SupervisorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Supervisors Management Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Attendance Records Content',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

