import 'dart:async'; // Import for Timer

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/user_cubit.dart'; // Make sure this path is correct
import 'package:pfa/Model/user_model.dart'; // Make sure this path is correct

// Enum to define message types for styling
enum MessageType { success, info, error, none }

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // New: Controller for the search bar
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery =
      ''; // New: State variable to hold the current search query

  User? _editingUser; // Renamed for consistency
  bool _isFormVisible = false; // Renamed for consistency

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Added for form validation

  // State variables for displaying messages within the popup
  String? _displayMessage;
  MessageType _displayMessageType = MessageType.none;
  Timer? _messageTimer; // Timer to clear the message automatically

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().fetchUsers();

    // New: Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _searchController.removeListener(_onSearchChanged); // New: Remove listener
    _searchController.dispose(); // New: Dispose search controller
    _messageTimer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  // New: Method to update search query and trigger rebuild
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _clearForm() {
    // Renamed for consistency
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _editingUser = null;
      _isFormVisible = false; // Hide form after clearing for new entry
    });
    _clearMessage(); // Clear any displayed message when form is cleared
  }

  void _populateForm(User user) {
    // Renamed for consistency
    _firstNameController.text = user.username;
    _lastNameController.text = user.lastname;
    _emailController.text = user.email;
    _passwordController.clear(); // Clear for security when editing

    setState(() {
      _editingUser = user;
      _isFormVisible = true; // Ensure the form becomes visible
    });
    _clearMessage(); // Clear any displayed message when populating form
  }

  void _submitForm() {
    // Renamed for consistency
    if (!_formKey.currentState!.validate()) {
      // Validate the form
      _displayMessageInPopup(
        'Please fill in all required fields.',
        MessageType.error,
      );
      return;
    }

    final newUser = User(
      userID: _editingUser?.userID,
      username: _firstNameController.text,
      lastname: _lastNameController.text,
      email: _emailController.text,
      password: _editingUser == null
          ? _passwordController
                .text // Only include password if adding
          : (_passwordController.text.isNotEmpty
                ? _passwordController.text
                : null), // Only send for update if not empty
      role: "Encadrant", // Assuming role is always 'Encadrant' for these users
    );

    if (_editingUser == null) {
      context.read<UserCubit>().addUser(newUser);
    } else {
      context.read<UserCubit>().updateUser(newUser);
    }
    // *** ADDED THIS LINE ***
    _clearForm(); // Clear the form and hide it after submission
  }

  void _deleteUser(int userId) {
    // Renamed for consistency
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserCubit>().deleteUser(userId);
              Navigator.of(ctx).pop(); // Close the confirmation dialog
              // The main AlertDialog will remain open, and message will appear there.
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleFormVisibility() {
    // Renamed for consistency
    setState(() {
      _isFormVisible = !_isFormVisible;
      if (!_isFormVisible) {
        _clearForm(); // Clear form if hiding and not editing
      }
    });
  }

  // Helper to display message within the popup
  void _displayMessageInPopup(String message, MessageType type) {
    setState(() {
      _displayMessage = message;
      _displayMessageType = type;
    });

    // Cancel any existing timer
    _messageTimer?.cancel();
    // Start a new timer to clear the message after 3 seconds
    _messageTimer = Timer(const Duration(seconds: 3), () {
      _clearMessage();
    });
  }

  // Helper to clear the displayed message
  void _clearMessage() {
    setState(() {
      _displayMessage = null;
      _displayMessageType = MessageType.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manage Supervisors'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Message display area
            AnimatedOpacity(
              opacity: _displayMessage != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _displayMessage != null
                  ? Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        color: _displayMessageType == MessageType.success
                            ? Colors.green.withOpacity(0.1)
                            : _displayMessageType == MessageType.info
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: _displayMessageType == MessageType.success
                              ? Colors.green
                              : _displayMessageType == MessageType.info
                              ? Colors.blue
                              : Colors.red,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _displayMessageType == MessageType.success
                                ? Icons.check_circle_outline
                                : _displayMessageType == MessageType.info
                                ? Icons.info_outline
                                : Icons.error_outline,
                            color: _displayMessageType == MessageType.success
                                ? Colors.green
                                : _displayMessageType == MessageType.info
                                ? Colors.blue
                                : Colors.red,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              _displayMessage!,
                              style: TextStyle(
                                color:
                                    _displayMessageType == MessageType.success
                                    ? Colors.green.shade800
                                    : _displayMessageType == MessageType.info
                                    ? Colors.blue.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // Toggle Button and Title for the Form Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _editingUser == null ? 'Add New User' : 'Edit User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () {
                    _toggleFormVisibility(); // Use the renamed method
                  },
                  icon: Icon(
                    _isFormVisible
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                  ),
                  tooltip: _isFormVisible ? 'Hide Form' : 'Show Form',
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: _isFormVisible
                  ? Padding(
                      key: const ValueKey('userForm'),
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Form(
                          // Added Form widget
                          key: _formKey, // Assigned GlobalKey
                          child: Column(
                            children: [
                              TextFormField(
                                // Changed to TextFormField
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'First Name cannot be empty.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                // Changed to TextFormField
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Last Name cannot be empty.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                // Changed to TextFormField
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email cannot be empty.';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              _editingUser == null
                                  ? TextFormField(
                                      // Changed to TextFormField
                                      controller: _passwordController,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.lock),
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (_editingUser == null &&
                                            (value == null || value.isEmpty)) {
                                          return 'Password is required for new users.';
                                        }
                                        return null;
                                      },
                                    )
                                  : const SizedBox.shrink(),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _clearForm, // Use renamed method
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Clear'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed:
                                        _submitForm, // Use renamed method
                                    icon: Icon(
                                      _editingUser == null
                                          ? Icons.add
                                          : Icons.save,
                                    ),
                                    label: Text(
                                      _editingUser == null
                                          ? 'Add User'
                                          : 'Update User',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const Divider(height: 30, thickness: 1),
            // New: Row for "Existing Supervisors" and Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Existing Supervisors',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2, // Give more space to the search bar
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search supervisors by name or email...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocConsumer<UserCubit, UserState>(
                listener: (context, state) {
                  // Display message within the popup for success or error
                  if (state is UserActionSuccess) {
                    _displayMessageInPopup(state.message, MessageType.success);
                    // No pop here, let the user see the message and close manually
                  } else if (state is UserError) {
                    _displayMessageInPopup(state.message, MessageType.error);
                    // No pop here, let the user see the message and close manually
                  }
                  // Removed the `Navigator.of(context).pop()` from the listener
                  // as the dialog now stays open to show the in-popup message.
                },
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserLoaded) {
                    // Filter users based on search query
                    final filteredUsers = state.users.where((user) {
                      final usernameLower = user.username.toLowerCase();
                      final lastnameLower = user.lastname.toLowerCase();
                      final emailLower = user.email.toLowerCase();
                      final searchQueryLower = _searchQuery.toLowerCase();

                      // Only show users with role 'Encadrant' or 'Admin'
                      final isSupervisor =
                          user.role == 'Encadrant' || user.role == 'Admin';

                      return isSupervisor &&
                          (usernameLower.contains(searchQueryLower) ||
                              lastnameLower.contains(searchQueryLower) ||
                              emailLower.contains(searchQueryLower));
                    }).toList();

                    if (filteredUsers.isEmpty && _searchQuery.isNotEmpty) {
                      return Center(
                        child: Text(
                          'No supervisors found matching "${_searchQuery}".',
                        ),
                      );
                    } else if (filteredUsers.isEmpty) {
                      return const Center(
                        child: Text(
                          'No supervisors found. Add one using the form above!',
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index]; // Use filtered list
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(user.username[0].toUpperCase()),
                            ),
                            title: Text(
                              '${user.username} ${user.lastname}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text('Email: ${user.email}')],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () =>
                                      _populateForm(user), // Use renamed method
                                  tooltip: 'Edit User',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteUser(
                                    user.userID!,
                                  ), // Use renamed method
                                  tooltip: 'Delete User',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is UserError) {
                    // If the error occurred during initial fetch, show the error message.
                    // Otherwise, the list will be shown, and the message in the AnimatedOpacity.
                    if (state.lastLoadedUsers == null ||
                        state.lastLoadedUsers!.isEmpty) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const SizedBox.shrink(); // Message handled by AnimatedOpacity
                  }
                  return const Center(
                    child: Text('Start managing users by adding one above.'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
