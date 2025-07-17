import 'package:flutter/material.dart';

class SidebarItemData {
  final IconData icon;
  final String label;
  final int index; // Index for IndexedStack
  final String?
  route; // GoRouter route if it's a top-level navigation, otherwise null
  final List<String> roles; // Roles that can see this item

  const SidebarItemData({
    required this.icon,
    required this.label,
    required this.index,
    this.route,
    required this.roles,
  });
}

// Define your sidebar items here
final List<SidebarItemData> gestionnaireSidebarItems = [
  const SidebarItemData(
    icon: Icons.dashboard,
    label: "Dashboard",
    index: 0,
    roles: ['Gestionnaire'],
  ),
  const SidebarItemData(
    icon: Icons.business,
    label: "Papers",
    index: 1,
    roles: ['Gestionnaire'],
  ),
  const SidebarItemData(
    icon: Icons.account_balance_wallet,
    label: "Accounting and Finance",
    index: 2,
    roles: ['Gestionnaire'],
  ),
  const SidebarItemData(
    icon: Icons.people,
    label: "Supervisors",
    index: 3,
    roles: ['Gestionnaire'],
  ),
  const SidebarItemData(
    icon: Icons.access_time,
    label: "Attendance",
    index: 4,
    roles: ['Gestionnaire'],
  ),
];

final List<SidebarItemData> encadrantSidebarItems = [
  const SidebarItemData(
    icon: Icons.dashboard,
    label: "Encadrant Dashboard",
    index: 0,
    roles: ['Encadrant'],
  ),
  const SidebarItemData(
    icon: Icons.person,
    label: "My Profile",
    index: 1,
    roles: ['Encadrant'],
  ),
  // Add other encadrant specific items
];

final List<SidebarItemData> chefSidebarItems = [
  const SidebarItemData(
    icon: Icons.settings,
    label: "Admin Panel",
    index: 0,
    roles: ['ChefCentreInformatique'],
  ),
  const SidebarItemData(
    icon: Icons.security, // Another example item
    label: "User Management",
    index: 1,
    roles: ['ChefCentreInformatique'],
  ),
  // Add other chef specific items
];

// Combine all items (optional, but useful if a single sidebar serves multiple roles)
final List<SidebarItemData> allSidebarItems = [
  ...gestionnaireSidebarItems,
  ...encadrantSidebarItems,
  ...chefSidebarItems,
  // Logout is common, but its index needs to be consistent
  // For now, handle logout separately as its action is special (GoRouter redirect)
];

// If you want a common "Log Out" item for all:
const SidebarItemData logoutSidebarItem = SidebarItemData(
  icon: Icons.logout,
  label: "Log Out",
  index: -1, // Use a special index or handle directly
  roles: ['Gestionnaire', 'Encadrant', 'ChefCentreInformatique'],
);
