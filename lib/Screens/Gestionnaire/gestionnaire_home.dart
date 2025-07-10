import 'package:flutter/material.dart';


class GestionnaireHome extends StatefulWidget {
  const GestionnaireHome({super.key});

  @override
  State<GestionnaireHome> createState() => _GestionnaireHomeState();
}

class _GestionnaireHomeState extends State<GestionnaireHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: [
            Text(
              'Welcome to the Gestioannaire Home Screen',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            ElevatedButton(
              onPressed: () {
                //GoRouter.g('/gestionnaire/inter_list');
              },
              child: Text("aaaa"),
            ),
          ],
        ),
      ),
    );
  }
}
