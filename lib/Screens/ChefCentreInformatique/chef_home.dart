import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pfa/Utils/Widgets/sidebar_item.dart';
import 'package:provider/provider.dart';
import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/utils/sidebar_config.dart';
import 'package:pfa/Screens/ChefCentreInformatique/chef_dashboard.dart';
// Make sure UserManagementScreen is defined or imported correctly
import 'package:pfa/Screens/ChefCentreInformatique/chef_user_management.dart'; // Assuming this path

class ChefHome extends StatefulWidget {
  const ChefHome({super.key});

  @override
  State<ChefHome> createState() => _ChefHomeState();
}

class _ChefHomeState extends State<ChefHome> {
  int _selectedIndex = 0; // Default to the first item (Dashboard)
  String? _currentUserRole;

  // The list of content pages for the sidebar
  final List<Widget> _chefContentPages = [
    const ChefDashboardScreen(), // Now contains the internship logic
    const UserManagementScreen(), // Your other screen
    // Add more screens here as needed for other sidebar items
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
    debugPrint('Fetched User Role in ChefHome: $role');
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
    final List<SidebarItemData> currentRoleSidebarItems = chefSidebarItems
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
                          //* Logo
                          const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Color(0xFF0A2847),
                              size: 40,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Text(
                            "Chef Panel",
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
                                ? -1 // Logout is not a content page
                                : item.index; // Use the index defined in sidebar_config for content pages
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
