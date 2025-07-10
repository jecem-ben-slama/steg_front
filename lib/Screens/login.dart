// lib/Screens/LoginScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/BLoc/Login/login_bloc.dart';
import 'package:pfa/BLoc/Login/login_event.dart';
import 'package:pfa/BLoc/Login/login_state.dart';
import 'package:pfa/Screens/Encadrant/encadrant_home.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_home.dart';
import 'package:pfa/Utils/Consts/style.dart';
import 'package:pfa/Utils/Widgets/input_field.dart';
import '../Utils/Consts/validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onLoginButtonPressed(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(
        LoginButtonPressed(
          email: emailController.text,
          password: passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double loginBoxWidth = screenWidth > 800 ? 800 : screenWidth * 0.9;
    final double loginBoxHeight = screenHeight > 600 ? 600 : screenHeight * 0.8;

    return Scaffold(
      backgroundColor: MyColors.lightBlue,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login Failed: ${state.error}')),
            );
          } else if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Login Successful! Welcome, ${state.username} (${state.role})',
                ),
              ),
            );

            if (state.role == 'Gestionnaire') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const GestionnaireHome(),
                ),
              );
            }
            
            if (state.role == 'Encadrant') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const EncadrantHome(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Role not recognized')),
              );
            }
          }
        },
        child: Center(
          //* Main Box
          child: Container(
            width: loginBoxWidth,
            height: loginBoxHeight,
            decoration: BoxDecoration(
              color: MyColors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                //* Left Half : Login Form
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: MyColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          //* Email Field - Using your InputField widget
                          InputField(
                            labelText: 'Email',
                            hintText: 'foulen@steg.com',
                            controller: emailController,
                            icon: Icons.email,
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 16),
                          //* Password Field - Using your InputField widget
                          InputField(
                            labelText: "Password",
                            hintText: "*********",
                            controller: passwordController,
                            obscure: true,
                            icon: Icons.lock,
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 24),
                          //* Login Button
                          BlocBuilder<LoginBloc, LoginState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state is LoginLoading
                                    ? null
                                    : () => onLoginButtonPressed(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.darkBlue,
                                  foregroundColor: MyColors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: state is LoginLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('Login'),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          //* Forgot Password
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Forgot Password?'),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //* Right Half : Image
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.black, // Background color for the image side
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20), // Corrected to topRight
                        bottomRight: Radius.circular(
                          20,
                        ), // Corrected to bottomRight
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/STEG.png', // Your image path
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.white70,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
