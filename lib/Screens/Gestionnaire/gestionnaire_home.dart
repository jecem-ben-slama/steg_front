import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:pfa/Screens/Gestionnaire/gestionnaire_details_page.dart';
import 'package:pfa/Repositories/login_repo.dart'; // Import LoginRepository to access logout

class GestionnaireHome extends StatefulWidget {
  const GestionnaireHome({super.key});

  @override
  State<GestionnaireHome> createState() => _GestionnaireHomeState();
}

class _GestionnaireHomeState extends State<GestionnaireHome> {
  int _selectedIndex =
      0; // 0: Dashboard, 1: Papers, 2: Accounting, 3: Supervisors, 4: Attendance, 5: Logout

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 5) {
      // Assuming index 5 is "Log Out"
      // Perform logout logic
      final loginRepository = RepositoryProvider.of<LoginRepository>(context);
      await loginRepository.deleteToken();
      GoRouter.of(context).go('/login'); // Redirect to login page
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0F7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            //* Sidebar
            Container(
              width: screenWidth * 0.2,
              height: screenHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF0A2847),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    //* Logo
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.dashboard,
                        color: Color(0xFF0A2847),
                        size: 40,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      "Micon Protocol",
                      style: TextStyle(
                        fontSize: screenWidth * 0.02,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    //* Navigation Items
                    SidebarItem(
                      icon: Icons.dashboard,
                      label: "Dashboard",
                      isSelected: _selectedIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.015),
                    SidebarItem(
                      icon: Icons.business,
                      label: "Papers",
                      isSelected: _selectedIndex == 1,
                      onTap: () => _onItemTapped(1),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.015),
                    SidebarItem(
                      icon: Icons.account_balance_wallet,
                      label: "Accounting and Finance",
                      isSelected: _selectedIndex == 2,
                      onTap: () => _onItemTapped(2),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.015),
                    SidebarItem(
                      icon: Icons.people,
                      label: "Supervisors",
                      isSelected: _selectedIndex == 3,
                      onTap: () => _onItemTapped(3),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.015),
                    SidebarItem(
                      icon: Icons.access_time,
                      label: "Attendance",
                      isSelected: _selectedIndex == 4,
                      onTap: () => _onItemTapped(4),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.06),
                    SidebarItem(
                      icon: Icons.logout,
                      label: "Log Out",
                      isSelected: _selectedIndex == 5,
                      onTap: () => _onItemTapped(5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            //* Main Content
            GestionnaireMainContent(
              selectedPageIndex: _selectedIndex, // Pass the selected index
            ),
          ],
        ),
      ),
    );
  }
}

// SidebarItem is now in gestionnaire_main_content.dart or a common widgets file.
// If you want to keep it here, make sure it's not duplicated.
// For this example, I'm assuming it's in gestionnaire_main_content.dart.

//! Sidebar item widget (No changes needed, can be moved to a separate file or kept here)
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // Added onTap callback
  final bool isSelected; // Added isSelected for visual feedback

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isSelected = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Use GestureDetector for better tap control
      onTap: onTap,
      child: Container(
        // Wrap with Container to apply background color based on selection
        color: isSelected
            ? Colors.blue.withOpacity(0.2)
            : Colors.transparent, // Highlight selected item
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.02,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.01,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal, // Make text bold if selected
            ),
          ),
        ),
      ),
    );
  }
}

// Keep StatCard and DeptCard in this file for now if they are only used in main content.
// If you're going to put SidebarItem in its own file, move these too.
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
