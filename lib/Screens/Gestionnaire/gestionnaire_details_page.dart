import 'package:flutter/material.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_dashboard.dart';

import 'package:pfa/Screens/Gestionnaire/certificates.dart';
import 'package:pfa/Screens/Gestionnaire/statistics.dart';
import 'package:pfa/Utils/logout.dart';

class GestionnaireMainContent extends StatefulWidget {
  final int selectedPageIndex; // Add selectedPageIndex as a parameter

  const GestionnaireMainContent({super.key, required this.selectedPageIndex});

  @override
  State<GestionnaireMainContent> createState() =>
      _GestionnaireMainContentState();
}

class _GestionnaireMainContentState extends State<GestionnaireMainContent> {
  final List<Widget> _pages = [
    const GestionnaireDashboard(),
    const Certificates(),
    const Statistics(),
    const Logout(),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: IndexedStack(
        // Use IndexedStack to efficiently switch between views
        index: widget.selectedPageIndex,
        children: _pages,
      ),
    );
  }
}
