import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/user_cubit.dart';
import 'package:pfa/Model/user_model.dart'; // Adjust path

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController =
      TextEditingController(); // Renamed for clarity
  User? editingUser;
  bool isFormVisible = false; // Renamed for clarity

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().fetchUsers();
  }

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    roleController.clear();
    setState(() {
      editingUser = null;
    });
  }

  void populateForm(User user) {
    firstNameController.text = user.username;
    lastNameController.text = user.lastname;
    emailController.text = user.email;
    roleController.text = user.role;
    setState(() {
      editingUser = user;
      isFormVisible = true; // Show the form when populating for editing
    });
  }

  void submitForm() {
    final newUser = User(
      userID: editingUser?.userID,
      username: firstNameController.text,
      lastname: lastNameController.text,
      email: emailController.text,
      role: roleController.text,
    );

    if (editingUser == null) {
      context.read<UserCubit>().addUser(newUser);
    } else {
      context.read<UserCubit>().updateUser(newUser);
    }
    clearForm();
    toggleFormVisibility(); // Hide the form after submission
  }

  void deleteUser(int userId) {
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
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void toggleFormVisibility() {
    setState(() {
      isFormVisible = !isFormVisible;
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
            // Toggle Button and Title for the Form Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  editingUser == null ? 'Add New User' : 'Edit User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: toggleFormVisibility,
                  icon: Icon(
                    isFormVisible
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                  ),
                  tooltip: isFormVisible ? 'Hide Form' : 'Show Form',
                ),
              ],
            ),
            // AnimatedSwitcher for smooth form visibility
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: isFormVisible
                  ? Padding(
                      key: const ValueKey(
                        'userForm',
                      ), // Key is important for AnimatedSwitcher
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: roleController,
                              decoration: const InputDecoration(
                                labelText: 'Role (e.g., Supervisor, Admin)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: clearForm,
                                  icon: const Icon(Icons.clear),
                                  label: const Text('Clear'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: submitForm,
                                  icon: Icon(
                                    editingUser == null
                                        ? Icons.add
                                        : Icons.save,
                                  ),
                                  label: Text(
                                    editingUser == null
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
                    )
                  : const SizedBox.shrink(), // Show nothing when hidden
            ),
            const Divider(height: 30, thickness: 1), // A clearer divider
            // User List Section Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Existing Supervisors',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocConsumer<UserCubit, UserState>(
                listener: (context, state) {
                  if (state is UserActionSuccess) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is UserError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserLoaded) {
                    if (state.users.isEmpty) {
                      return const Center(
                        child: Text(
                          'No supervisors found. Add one using the form above!',
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          elevation: 3, // Add some shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                user.username[0].toUpperCase(),
                              ), // First letter of username
                            ),
                            title: Text(
                              '${user.username} ${user.lastname}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${user.email}'),
                                Text('Role: ${user.role ?? 'N/A'}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => populateForm(user),
                                  tooltip: 'Edit User',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteUser(user.userID!),
                                  tooltip: 'Delete User',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is UserError) {
                    return Center(child: Text('Error: ${state.message}'));
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
