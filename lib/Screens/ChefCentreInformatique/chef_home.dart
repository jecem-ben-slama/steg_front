// lib/Screens/ChefCentreInformatique/chef_home.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pfa/Utils/Widgets/sidebar_item.dart';
import 'package:provider/provider.dart';
import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/utils/sidebar_config.dart';

// Import your Chef-specific screens
import 'package:pfa/Screens/ChefCentreInformatique/chef_dashboard.dart';
// import 'package:pfa/Screens/ChefCentreInformatique/user_management_screen.dart'; // Example

class ChefHome extends StatefulWidget {
  const ChefHome({super.key});

  @override
  State<ChefHome> createState() => _ChefHomeState();
}

class _ChefHomeState extends State<ChefHome> {
  int _selectedIndex = 0;
  String? _currentUserRole;

  // List of content widgets for Chef
  final List<Widget> _chefContentPages = [
    const ChefDashboardScreen(), // Matches index 0 in chefSidebarItems
    const UserManagementScreen(), // Matches index 1 in chefSidebarItems
    // Add other Chef specific views here, in the order of their 'index' in sidebar_config.dart
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
    debugPrint('Fetched User Role in ChefHome: $role'); // For debugging
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

    // Filter sidebar items based on the current user's role
    final List<SidebarItemData> currentRoleSidebarItems = chefSidebarItems
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
                          //* Logo (can be dynamic based on role or a generic app logo)
                          const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons
                                  .admin_panel_settings, // Example icon for Chef
                              color: Color(0xFF0A2847),
                              size: 40,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Text(
                            "Chef Panel", // Role-specific title
                            style: TextStyle(
                              fontSize: screenWidth * 0.02,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          //* Navigation Items
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
                            _selectedIndex < _chefContentPages.length
                        ? _chefContentPages[_selectedIndex]
                        : const Center(
                            child: Text("Select an option"),
                          ), // Fallback
                  ),
                ],
              ),
            ),
    );
  }
}
