// lib/Screens/ChefCentreInformatique/gestionnaire_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Screens/ChefCentreInformatique/gestionnaire_management_popup.dart';
import 'package:pfa/cubit/user_cubit.dart';
import 'package:pfa/Model/user_model.dart';

class GestionnaireManagementScreen extends StatefulWidget {
  const GestionnaireManagementScreen({super.key});

  @override
  State<GestionnaireManagementScreen> createState() =>
      _GestionnaireManagementScreenState();
}

class _GestionnaireManagementScreenState
    extends State<GestionnaireManagementScreen> {
  final List<String> _availableRoles = [
    'All Staff',
    'Gestionnaire',
    'Encadrant',
  ];
  String _selectedRoleFilter = 'All Staff'; // Default filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // State to hold the current search query

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().fetchUsers();

    // Listen to changes in the search text field
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Update the search query and trigger a rebuild
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Staff Users'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRoleFilter,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                dropdownColor: Theme.of(context).primaryColor,
                style: const TextStyle(color: Colors.white),
                onChanged: (String? newValue) {
                  if (newValue != null && newValue != _selectedRoleFilter) {
                    setState(() {
                      _selectedRoleFilter = newValue;
                    });
                  }
                },
                items: _availableRoles.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showUserFormDialog(context, null);
            },
          ),
        ],
      ),
      body: Column(
        // Use Column to place search bar above the list
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged(); // Clear the search query
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            // Wrap BlocConsumer with Expanded to take remaining space
            child: BlocConsumer<UserCubit, UserState>(
              listener: (context, state) {
                if (state is UserActionSuccess) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                  context.read<UserCubit>().fetchUsers();
                } else if (state is UserError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                List<User> usersToDisplay = [];
                bool isLoading = false;

                if (state is UserLoading) {
                  isLoading = true;
                } else if (state is UserLoaded) {
                  usersToDisplay = state.users;
                } else if (state is UserActionSuccess &&
                    state.lastLoadedUsers != null) {
                  usersToDisplay = state.lastLoadedUsers!;
                } else if (state is UserError &&
                    state.lastLoadedUsers != null) {
                  usersToDisplay = state.lastLoadedUsers!;
                }

                // Apply role filter
                if (_selectedRoleFilter == 'All Staff') {
                  usersToDisplay = usersToDisplay
                      .where(
                        (user) =>
                            user.role == 'Gestionnaire' ||
                            user.role == 'Encadrant',
                      )
                      .toList();
                } else {
                  usersToDisplay = usersToDisplay
                      .where((user) => user.role == _selectedRoleFilter)
                      .toList();
                }

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  usersToDisplay = usersToDisplay.where((user) {
                    final username = user.username.toLowerCase();
                    final lastname = user.lastname.toLowerCase();
                    final email = user.email.toLowerCase();
                    return username.contains(query) ||
                        lastname.contains(query) ||
                        email.contains(query);
                  }).toList();
                }

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (usersToDisplay.isEmpty) {
                  // Adjust message based on whether search is active
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No users found for "${_searchQuery}" in "${_selectedRoleFilter}".'
                          : 'No $_selectedRoleFilter users found.',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: usersToDisplay.length,
                  itemBuilder: (context, index) {
                    final user = usersToDisplay[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        title: Text(
                          '${user.username} ${user.lastname} (${user.role})',
                        ),
                        subtitle: Text(user.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showUserFormDialog(context, user);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDelete(context, user);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUserFormDialog(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<UserCubit>(context),
          child: GestionnaireManagementPopup(user: user),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete ${user.username} ${user.lastname}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                if (user.userID != null) {
                  context.read<UserCubit>().deleteUser(user.userID!);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot delete user without an ID.'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
