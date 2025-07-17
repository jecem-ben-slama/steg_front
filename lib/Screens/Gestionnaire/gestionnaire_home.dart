import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:pfa/Screens/Gestionnaire/gestionnaire_details_page.dart';
import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/Utils/Widgets/sidebar_item.dart'; // Import LoginRepository to access logout

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
    
      final loginRepository = RepositoryProvider.of<LoginRepository>(context);
      await loginRepository.deleteToken();
      GoRouter.of(context).go('/login'); 
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

