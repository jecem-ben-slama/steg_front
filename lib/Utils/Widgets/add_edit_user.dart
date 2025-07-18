// lib/Widgets/add_edit_supervisor_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Cubit/user_cubit.dart'; // Using your existing UserCubit
import 'package:pfa/Model/user_model.dart'; // Using your existing User model
import 'package:pfa/Utils/snackbar.dart'; // Assuming you have this utility

class AddEditSupervisorDialog extends StatefulWidget {
  final User? supervisor; // Null for add, non-null for edit

  const AddEditSupervisorDialog({super.key, this.supervisor});

  @override
  State<AddEditSupervisorDialog> createState() =>
      _AddEditSupervisorDialogState();
}

class _AddEditSupervisorDialogState extends State<AddEditSupervisorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _lastnameController;
  String? _selectedRole; // To hold the selected role for the supervisor

  final List<String> _supervisorRoles = [
    'Encadrant',
    'Gestionnaire',
  ]; // Roles allowed for supervisors

  bool _isEditing = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.supervisor != null;
    _usernameController = TextEditingController(
      text: widget.supervisor?.username ?? '',
    );
    _emailController = TextEditingController(
      text: widget.supervisor?.email ?? '',
    );
    _passwordController =
        TextEditingController(); // Password is not pre-filled for security
    _lastnameController = TextEditingController(
      text: widget.supervisor?.lastname ?? '',
    );
    _selectedRole =
        widget.supervisor?.role ??
        _supervisorRoles.first; // Default to first role if adding
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String username = _usernameController.text;
      final String email = _emailController.text;
      final String password =
          _passwordController.text; // Will be empty string if not entered
      final String lastname = _lastnameController.text;
      final String role = _selectedRole!;

      if (_isEditing) {
        final updatedSupervisor = widget.supervisor!.copyWith(
          username: username,
          email: email,
          lastname: lastname,
          role: role,
          // Only update password if it's not empty, otherwise keep existing or null
          password: password.isNotEmpty ? password : null,
        );
        context.read<UserCubit>().updateUser(updatedSupervisor);
      } else {
        // Password is required for new user creation based on your repo logic
        if (password.isEmpty) {
          showFailureSnackBar(
            context,
            'Password is required for new supervisor.',
          );
          return;
        }
        final newSupervisor = User(
          username: username,
          email: email,
          password: password,
          lastname: lastname,
          role: role,
        );
        context.read<UserCubit>().addUser(newSupervisor);
      }
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Supervisor' : 'Add New Supervisor',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastnameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password field is required for new users, optional for editing
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: _isEditing
                      ? 'New Password (Optional)'
                      : 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (!_isEditing && (value == null || value.isEmpty)) {
                    return 'Password is required.';
                  }
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                items: _supervisorRoles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(_isEditing ? 'Update' : 'Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
