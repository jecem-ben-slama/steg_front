// lib/Screens/Gestionnaire/gestionnaire_home.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pfa/Screens/Gestionnaire/Certificates.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_dashboard.dart';
import 'package:pfa/Screens/Gestionnaire/statistics.dart';
import 'package:pfa/Utils/Widgets/sidebar_item.dart';
import 'package:provider/provider.dart';

// Import from your Widgets folder

// Your statistics screen (example for 'Accounting and Finance')
// Import your other Gestionnaire screens here
// import 'package:pfa/Gestionnaire/supervisors_management.dart';
// import 'package:pfa/Gestionnaire/attendance_records.dart';

import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/utils/sidebar_config.dart'; // Import the new sidebar config

class GestionnaireHome extends StatefulWidget {
  const GestionnaireHome({super.key});

  @override
  State<GestionnaireHome> createState() => _GestionnaireHomeState();
}

class _GestionnaireHomeState extends State<GestionnaireHome> {
  int _selectedIndex = 0; 
  String? _currentUserRole; 
  final List<Widget> _gestionnaireContentPages = [
    const GestionnaireDashboard(), 
    const Certificates(), 
    const Statistics(), 
    const Text('Supervisors Screen Placeholder'), 
    const Text('Attendance Screen Placeholder'), 
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final loginRepository = Provider.of<LoginRepository>(
      context,
      listen: false,
    );
    final role = await loginRepository.getUserRoleFromToken();
    setState(() {
      _currentUserRole = role;
    });
  }

  void _onItemTapped(int index, SidebarItemData itemData) async {
    setState(() {
      _selectedIndex = index;
    });

    if (itemData.label == logoutSidebarItem.label) {
      // Handle logout
      final loginRepository = Provider.of<LoginRepository>(
        context,
        listen: false,
      );
      await loginRepository.deleteToken();
      GoRouter.of(context).go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Filter sidebar items based on the current user's role
    final List<SidebarItemData> currentRoleSidebarItems =
        gestionnaireSidebarItems
            .where((item) => item.roles.contains(_currentUserRole))
            .toList();

    // Add the common logout item at the end
    if (_currentUserRole != null &&
        logoutSidebarItem.roles.contains(_currentUserRole)) {
      currentRoleSidebarItems.add(logoutSidebarItem);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0F7),
      body: _currentUserRole == null
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Show loading while role is being fetched
          : Padding(
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
                          // Dynamically build sidebar items based on role
                          ...currentRoleSidebarItems.map((item) {
                            // Determine the actual index for content display (skip -1 for logout)
                            final contentIndex =
                                (item.label == logoutSidebarItem.label)
                                ? -1
                                : item.index;

                            return SidebarItem(
                              icon: item.icon,
                              label: item.label,
                              isSelected: _selectedIndex == contentIndex,
                              onTap: () => _onItemTapped(contentIndex, item),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  //* Main Content
                  Expanded(
                    child:
                        _selectedIndex >= 0 &&
                            _selectedIndex < _gestionnaireContentPages.length
                        ? _gestionnaireContentPages[_selectedIndex]
                        : const Center(
                            child: Text("Select an option"),
                          ), // Fallback or initial message
                  ),
                ],
              ),
            ),
    );
  }
}
