import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/cubit/user_cubit.dart';
import 'package:pfa/Model/user_model.dart';
import 'package:pfa/Repositories/login_repo.dart'; // Import LoginRepository

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _lastnameController;
  late TextEditingController _passwordController;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _lastnameController = TextEditingController();
    _passwordController = TextEditingController();

    // Get user ID from LoginRepository's stored token
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loginRepository = context
          .read<LoginRepository>(); // Access LoginRepository
      final int? userId = await loginRepository
          .getUserIdFromToken(); // Get user ID

      if (userId != null) {
        // Only fetch profile if a user ID is found
        context.read<UserCubit>().fetchCurrentUserProfile(userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found in token. Please log in.'),
          ),
        );
        // Optionally, navigate to login if userId is null
        // GoRouter.of(context).go('/login');
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _lastnameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateControllers(User user) {
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _lastnameController.text = user.lastname;
    _passwordController.clear(); // Clear password field after data load/update
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_currentUser == null || _currentUser!.userID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot update profile: User data not loaded.'),
          ),
        );
        return;
      }

      final String username = _usernameController.text;
      final String email = _emailController.text;
      final String lastname = _lastnameController.text;
      final String password = _passwordController.text;

      final updatedUser = _currentUser!.copyWith(
        username: username,
        email: email,
        lastname: lastname,
        password: password.isNotEmpty
            ? password
            : null, // Only update if new password provided
        role: _currentUser!.role, // Keep the original role
      );

      context.read<UserCubit>().updateUser(updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            if (state.updatedUser != null &&
                state.updatedUser!.userID == _currentUser?.userID) {
              _updateControllers(state.updatedUser!);
              _currentUser = state.updatedUser;
            }
          } else if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
            if (state.lastLoadedUser != null) {
              _updateControllers(state.lastLoadedUser!);
              _currentUser = state.lastLoadedUser;
            }
          } else if (state is UserProfileLoaded) {
            _updateControllers(state.user);
            _currentUser = state.user;
          }
        },
        builder: (context, state) {
          bool isLoading = false;
          User? displayUser;

          if (state is UserProfileLoading) {
            isLoading = true;
          } else if (state is UserProfileLoaded) {
            displayUser = state.user;
          } else if (state is UserActionSuccess && state.updatedUser != null) {
            displayUser = state.updatedUser;
          } else if (state is UserError && state.lastLoadedUser != null) {
            displayUser = state.lastLoadedUser;
          }

          if (isLoading || displayUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Role: ${displayUser.role}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'New Password (leave blank to keep current)',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Update Profile'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
