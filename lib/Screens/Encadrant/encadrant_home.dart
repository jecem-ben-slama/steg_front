// lib/Screens/Encadrant/encadrant_home.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pfa/Screens/Encadrant/encadrant_dashboard.dart';
import 'package:pfa/Screens/Encadrant/encadrant_notes.dart';
import 'package:pfa/Screens/profile_screen.dart'; // Ensure this path is correct
import 'package:pfa/Utils/Widgets/sidebar_item.dart';
import 'package:provider/provider.dart';
import 'package:pfa/Repositories/login_repo.dart'; // Ensure this path is correct
import 'package:pfa/utils/sidebar_config.dart'; // Ensure this path is correct

class EncadrantHome extends StatefulWidget {
  const EncadrantHome({super.key});

  @override
  State<EncadrantHome> createState() => _EncadrantHomeState();
}

class _EncadrantHomeState extends State<EncadrantHome> {
  int _selectedIndex = 0;
  String? _currentUserRole;

  // IMPORTANT: Updated _encadrantContentPages
  late final List<Widget> _encadrantContentPages;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();

    // Initialize the content pages here
    // Index 0: Placeholder for Encadrant Dashboard
    // Index 1: Your existing ProfileScreen
    _encadrantContentPages = [
      const EncadrantDashboard(),
      const EncadrantNotesPage(), // Placeholder for Dashboard
      const ProfileScreen(), // Your existing ProfileScreen
    ];
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

    final List<SidebarItemData> currentRoleSidebarItems = encadrantSidebarItems
        .where((item) => item.roles.contains(_currentUserRole))
        .toList();

    if (_currentUserRole != null &&
        logoutSidebarItem.roles.contains(_currentUserRole)) {
      currentRoleSidebarItems.add(logoutSidebarItem);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6F0F7),
      body: _currentUserRole == null
          ? const Center(child: CircularProgressIndicator())
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
                          const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF0A2847),
                              size: 40,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Text(
                            "Encadrant Panel",
                            style: TextStyle(
                              fontSize: screenWidth * 0.02,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          ...currentRoleSidebarItems.map((item) {
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
                            _selectedIndex < _encadrantContentPages.length
                        ? _encadrantContentPages[_selectedIndex]
                        : const Center(child: Text("Select an option")),
                  ),
                ],
              ),
            ),
    );
  }
}
