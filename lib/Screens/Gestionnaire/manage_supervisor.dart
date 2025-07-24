import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/user_cubit.dart';
import 'package:pfa/Model/user_model.dart';

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  User? editingUser;
  bool isFormVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().fetchUsers();
  }

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    passwordController.clear();
    setState(() {
      editingUser = null;
    });
  }

  void populateForm(User user) {
    firstNameController.text = user.username;
    lastNameController.text = user.lastname;
    emailController.text = user.email;
    passwordController.clear(); // Clear for security when editing

    setState(() {
      editingUser = user;
      isFormVisible = true; // Ensure the form becomes visible
    });
  }

  void submitForm() {
    final newUser = User(
      userID: editingUser?.userID,
      username: firstNameController.text,
      lastname: lastNameController.text,
      email: emailController.text,
      password: editingUser == null
          ? passwordController
                .text // Only include password if adding
          : (passwordController.text.isNotEmpty
                ? passwordController.text
                : null), // Only send for update if not empty
      role: "Encadrant", // Assuming role is always 'Encadrant' for these users
    );

    if (editingUser == null) {
      context.read<UserCubit>().addUser(newUser);
    } else {
      context.read<UserCubit>().updateUser(newUser);
    }
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
              Navigator.of(ctx).pop(); // Close the confirmation dialog
              // The main AlertDialog will be closed by the listener
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
      if (!isFormVisible) {
        clearForm();
      }
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
                  onPressed: () {
                    if (editingUser != null) {
                      clearForm();
                    }
                    toggleFormVisibility();
                  },
                  icon: Icon(
                    isFormVisible
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                  ),
                  tooltip: isFormVisible ? 'Hide Form' : 'Show Form',
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: isFormVisible
                  ? Padding(
                      key: const ValueKey('userForm'),
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
                            editingUser == null
                                ? TextField(
                                    controller: passwordController,
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.lock),
                                    ),
                                    obscureText: true,
                                  )
                                : const SizedBox.shrink(),
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
                  : const SizedBox.shrink(),
            ),
            const Divider(height: 30, thickness: 1),
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
                  // Display SnackBar for success or error
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

                  // Close the AlertDialog after any action (success or error)
                  if (state is UserActionSuccess || state is UserError) {
                    // It's good practice to clear the form and hide it
                    // after an action, especially if the dialog closes.
                    clearForm();
                    // No need to call toggleFormVisibility if dialog closes.
                    Navigator.of(context).pop(); // <--- MOVED THIS LINE
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
