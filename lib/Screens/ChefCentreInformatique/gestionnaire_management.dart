import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Screens/ChefCentreInformatique/gestionnaire_management_popup.dart'; // Assuming this is your form widget
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

  User? _userToEdit; // Holds the user being edited, null if adding new
  bool _showForm = false; // Controls whether to show the form or the list

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // Method to show the form for adding a new user
  void _showAddUserForm() {
    setState(() {
      _userToEdit = null; // No user for adding
      _showForm = true; // Show the form
    });
  }

  // Method to show the form for editing an existing user
  void _showEditUserForm(User user) {
    setState(() {
      _userToEdit = user; // Set the user to be edited
      _showForm = true; // Show the form
    });
  }

  // Callback function for when the form is submitted or cancelled
  void _onFormActionCompleted() {
    setState(() {
      _showForm = false; // Hide the form
      _userToEdit = null; // Clear the user being edited
    });
    // Refresh the user list after an action (add/edit/cancel)
    context.read<UserCubit>().fetchUsers();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showForm
              ? (_userToEdit == null ? 'Add New Staff User' : 'Edit Staff User')
              : 'Manage Staff Users',
        ),
        actions: [
          if (!_showForm) // Only show filter and add button when list is visible
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
          if (!_showForm) // Only show add button when list is visible
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddUserForm, // Call the method to show add form
            ),
          if (_showForm) // Show a "Cancel" button when the form is visible
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _onFormActionCompleted, // Hide the form
            ),
        ],
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // IMPORTANT: Hide the form and refresh only after a successful action
            _onFormActionCompleted();
          } else if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
            // If there's an error, you might want to keep the form open for correction
            // Or hide it based on your UX preference. For now, keep it open.
          }
        },
        builder: (context, state) {
          // Determine the list of users to display based on the current state
          List<User> usersToDisplay = [];
          bool isLoading = false;

          if (state is UserLoading) {
            isLoading = true;
          } else if (state is UserLoaded) {
            usersToDisplay = state.users;
          } else if (state is UserActionSuccess &&
              state.lastLoadedUsers != null) {
            usersToDisplay = state.lastLoadedUsers!;
          } else if (state is UserError && state.lastLoadedUsers != null) {
            usersToDisplay = state.lastLoadedUsers!;
          }

          // Apply role filter
          if (_selectedRoleFilter == 'All Staff') {
            usersToDisplay = usersToDisplay
                .where(
                  (user) =>
                      user.role == 'Gestionnaire' || user.role == 'Encadrant',
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

          return Column(
            children: [
              // AnimatedSwitcher for the form
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(sizeFactor: animation, child: child);
                },
                child: _showForm
                    ? Padding(
                        // Add padding around the form
                        key: const ValueKey(
                          'GestionnaireForm',
                        ), // Unique key for AnimatedSwitcher
                        padding: const EdgeInsets.all(16.0),
                        child: GestionnaireFormScreen(
                          user: _userToEdit,
                          // The onFormActionCompleted callback is now redundant here
                          // because the BlocListener handles hiding the form.
                        ),
                      )
                    : const SizedBox.shrink(), // Hide the form when not visible
              ),
              if (!_showForm) // Only show search bar and list when form is hidden
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
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (usersToDisplay.isEmpty &&
                  !_showForm) // Only show empty message if not showing the form
                Expanded(
                  child: Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'No users found for "$_searchQuery" in "$_selectedRoleFilter".'
                          : 'No $_selectedRoleFilter users found.',
                    ),
                  ),
                )
              else if (!_showForm) // Only show the list if the form is hidden
                Expanded(
                  child: ListView.builder(
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
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _showEditUserForm(user); // Show edit form
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _confirmDelete(context, user);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
