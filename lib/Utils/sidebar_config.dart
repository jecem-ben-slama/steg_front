import 'package:flutter/material.dart';

class SidebarItemData {
  final IconData icon;
  final String label;
  final int index;
  final String? route;
  final List<String> roles;

  const SidebarItemData({
    required this.icon,
    required this.label,
    required this.index,
    this.route,
    required this.roles,
  });
}

//* Sidebar items for Gestionnaire
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
    label: "My Profile",
    index: 4,
    roles: ['Gestionnaire'],
  ),
];

//* Sidebar items for Encadrant
final List<SidebarItemData> encadrantSidebarItems = [
  const SidebarItemData(
    icon: Icons.dashboard,
    label: "Encadrant Dashboard",
    index: 0,
    roles: ['Encadrant'],
  ),
  const SidebarItemData(
    icon: Icons.dashboard,
    label: "Add Notes",
    index: 1,
    roles: ['Encadrant'],
  ),
  const SidebarItemData(
    icon: Icons.person,
    label: "Evaluations",
    index: 2,
    roles: ['Encadrant'],
  ),
  const SidebarItemData(
    icon: Icons.person,
    label: "My Profile",
    index: 3,
    roles: ['Encadrant'],
  ),
];

//* Sidebar items for ChefCentreInformatique
final List<SidebarItemData> chefSidebarItems = [
  const SidebarItemData(
    icon: Icons.settings,
    label: "Admin Panel",
    index: 0,
    roles: ['ChefCentreInformatique'],
  ),
  const SidebarItemData(
    icon: Icons.security,
    label: "User Management",
    index: 1,
    roles: ['ChefCentreInformatique'],
  ),
  const SidebarItemData(
    icon: Icons.person,
    label: "Validate Evaluations",
    index: 2,
    roles: ['ChefCentreInformatique'],
  ),
  const SidebarItemData(
    icon: Icons.person,
    label: "My Profile",
    index: 3,
    roles: ['ChefCentreInformatique'],
  ),
];

final List<SidebarItemData> allSidebarItems = [
  ...gestionnaireSidebarItems,
  ...encadrantSidebarItems,
  ...chefSidebarItems,
];

const SidebarItemData logoutSidebarItem = SidebarItemData(
  icon: Icons.logout,
  label: "Log Out",
  index: -1,
  roles: ['Gestionnaire', 'Encadrant', 'ChefCentreInformatique'],
);
