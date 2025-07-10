import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_home.dart';
import 'package:pfa/Screens/login.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  late Future<String?> authStatusFuture;
//! This file checks if a user is already logged in
  @override
  void initState() {
    super.initState();
    authStatusFuture = _checkAuthStatus();
  }

  Future<String?> _checkAuthStatus() async {
   
    final loginRepository = context.read<LoginRepository>();
    final String? token = await loginRepository.getToken();

    if (token != null) {
    
      debugPrint('AuthCheck: Token found. ');
      await Future.delayed(const Duration(milliseconds: 500));
      return 'authenticated';
    } else {
      debugPrint('AuthCheck: No token found.');
      await Future.delayed(const Duration(milliseconds: 500));
      return 'unauthenticated';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: authStatusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          debugPrint('AuthCheck Error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text('Error checking auth status: ${snapshot.error}'),
            ),
          );
        } else {
          
          if (snapshot.data == 'authenticated') {   
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => GestionnaireHome()),
              );
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        }
      },
    );
  }
}
