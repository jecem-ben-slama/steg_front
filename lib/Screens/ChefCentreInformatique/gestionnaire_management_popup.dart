import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/user_cubit.dart';
import 'package:pfa/Model/user_model.dart';

class GestionnaireFormScreen extends StatefulWidget {
  final User? user; // Null if adding, non-null if editing

  const GestionnaireFormScreen({super.key, this.user});

  @override
  State<GestionnaireFormScreen> createState() => _GestionnaireFormScreenState();
}

class _GestionnaireFormScreenState extends State<GestionnaireFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _lastnameController;
  late TextEditingController _passwordController;
  late String _selectedRole;

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
    _selectedRole = widget.user?.role ?? 'Gestionnaire';
  }

  @override
  void didUpdateWidget(covariant GestionnaireFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user != oldWidget.user) {
      _usernameController.text = widget.user?.username ?? '';
      _emailController.text = widget.user?.email ?? '';
      _lastnameController.text = widget.user?.lastname ?? '';
      _passwordController.clear();
      _selectedRole = widget.user?.role ?? 'Gestionnaire';
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
          role: _selectedRole,
          password: password.isNotEmpty ? password : null,
        );
        context.read<UserCubit>().addUser(newUser);
      } else {
        // Update existing user
        final updatedUser = widget.user!.copyWith(
          username: username,
          email: email,
          lastname: lastname,
          role: _selectedRole,
          password: password.isNotEmpty ? password : null,
        );
        context.read<UserCubit>().updateUser(updatedUser);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        // No need to show snackbars here, parent listener handles it.
        // Also, no need to pop here, parent listener handles hiding the form.
      },
      builder: (context, state) {
        final bool isLoading = state is UserLoading;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    // Validate that the value only contains letters (and spaces)
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Username can only contain letters and spaces.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a last name';
                    }
                    // Validate that the value only contains letters (and spaces)
                    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                      return 'Last name can only contain letters and spaces.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
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
                const SizedBox(height: 16.0),
                if (widget.user == null)
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (widget.user == null &&
                          (value == null || value.isEmpty)) {
                        return 'Password is required for new user';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Gestionnaire',
                      child: Text('Gestionnaire'),
                    ),
                    DropdownMenuItem(
                      value: 'Encadrant',
                      child: Text('Encadrant'),
                    ),
                    DropdownMenuItem(
                      value: 'Chef Centre',
                      child: Text('Chef Centre'),
                    ),
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
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: (state is UserLoading) ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: (state is UserLoading)
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.user == null
                              ? 'Add Staff User'
                              : 'Update Staff User',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
