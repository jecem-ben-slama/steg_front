import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/user_cubit.dart';
import 'package:pfa/Model/user_model.dart';

class GestionnaireManagementPopup extends StatefulWidget {
  final User? user; 

  const GestionnaireManagementPopup({super.key, this.user});

  @override
  State<GestionnaireManagementPopup> createState() => _GestionnaireManagementPopupState();
}

class _GestionnaireManagementPopupState extends State<GestionnaireManagementPopup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _lastnameController;
  late TextEditingController _passwordController;
  String _selectedRole = 'Gestionnaire'; // Default role when adding

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.user?.username ?? '',
    );
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _lastnameController = TextEditingController(
      text: widget.user?.lastname ?? '',
    );
    _passwordController = TextEditingController(text: '');
    if (widget.user != null) {
      _selectedRole = widget.user!.role; // Pre-fill with existing role for edit
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _lastnameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final String username = _usernameController.text;
      final String email = _emailController.text;
      final String lastname = _lastnameController.text;
      final String password = _passwordController.text;

      if (widget.user == null) {
        // Add new user
        final newUser = User(
          username: username,
          email: email,
          lastname: lastname,
          role: _selectedRole, // Use the selected role
          password: password.isNotEmpty ? password : null,
        );
        context.read<UserCubit>().addUser(newUser);
      } else {
        // Update existing user
        final updatedUser = widget.user!.copyWith(
          username: username,
          email: email,
          lastname: lastname,
          role: _selectedRole, // Update with the selected role
          password: password.isNotEmpty ? password : null,
        );
        context.read<UserCubit>().updateUser(updatedUser);
      }
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.user == null ? 'Add New Staff User' : 'Edit Staff User',
      ), // More generic title
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastnameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              if (widget.user ==
                  null) // Password field shown only for adding new user
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      // Password is required for new user
                      return 'Password is required for new user';
                    }
                    return null;
                  },
                ),
              // Role selection for adding/editing users
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(
                    value: 'Gestionnaire',
                    child: Text('Gestionnaire'),
                  ),
                  DropdownMenuItem(
                    value: 'Encadrant',
                    child: Text('Encadrant'),
                  ),
                  // Add other roles here if the Chef can assign them during creation/edit
                  // e.g., DropdownMenuItem(value: 'ChefCentreInformatique', child: Text('Chef Centre Informatique')),
                  // BUT BE CAREFUL with allowing role changes to critical roles like 'ChefCentreInformatique'
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      _selectedRole = newValue;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(widget.user == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
