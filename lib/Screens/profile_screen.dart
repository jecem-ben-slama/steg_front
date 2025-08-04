import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Utils/Consts/style.dart';
import 'package:pfa/Utils/Consts/validator.dart';
import 'package:pfa/cubit/user_cubit.dart';
import 'package:pfa/Model/user_model.dart';
import 'package:pfa/Repositories/login_repo.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loginRepository = context.read<LoginRepository>();
      final int? userId = await loginRepository.getUserIdFromToken();

      if (userId != null) {
        context.read<UserCubit>().fetchCurrentUserProfile(userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found in token. Please log in.'),
          ),
        );
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
    _passwordController.clear();
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
        password: password.isNotEmpty ? password : null,
        role: _currentUser!.role,
      );

      context.read<UserCubit>().updateUser(updatedUser);
    }
  }

  String displayRole(String userRole) {
    switch (userRole) {
      case 'Encadrant':
        return "Supervisor";
      case 'ChefCentreInformatique':
        return "IT center manager";
      case "Gestionnaire":
        return "administrator";
      default:
        return "Unknown role";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Section
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueGrey,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${displayUser.username} ${displayUser.lastname}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        Text(
                          displayRole(displayUser.role),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  // Form Section in a Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                             validator: Validators.validateName,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _lastnameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            validator: Validators.validateName,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an email';
                                }
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'New Password (leave blank)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Update Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: MyColors.darkBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Update Profile'),
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
