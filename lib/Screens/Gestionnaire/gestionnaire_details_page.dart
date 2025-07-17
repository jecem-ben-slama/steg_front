import 'package:flutter/material.dart';
import 'package:pfa/Screens/Gestionnaire/papers.dart';
// Import the new views

// Remove SidebarItem, StatCard, DeptCard from here if you put them in separate files.
// For now, I'm keeping them in this file if they are primarily used by the gestionnaire views.
// If SidebarItem is shared, move it to a common widgets folder.
// For this example, let's assume StatCard and DeptCard are unique to gestionnaire views.

class GestionnaireMainContent extends StatefulWidget {
  final int selectedPageIndex; // Add selectedPageIndex as a parameter

  const GestionnaireMainContent({super.key, required this.selectedPageIndex});

  @override
  State<GestionnaireMainContent> createState() =>
      _GestionnaireMainContentState();
}

class _GestionnaireMainContentState extends State<GestionnaireMainContent> {
  final List<Widget> _pages = [
    const DashboardView(),
    const PapersView(),
    const AccountingFinanceView(),
    const SupervisorsView(),
    const AttendanceView(),
    const LogoutView(), // This might trigger logout logic directly in onPressed
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

// You still need StatCard and DeptCard if they are used by DashboardView
//! Stat card widget (No changes needed)
class StatCard extends StatelessWidget {
  final String title, value;
  const StatCard({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.13,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const Text("See More", style: TextStyle(color: Colors.green)),
        ],
      ),
    );
  }
}

//! Department card widget (No changes needed)
class DeptCard extends StatelessWidget {
  final String title;
  const DeptCard({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
