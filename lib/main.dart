// lib/main.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pfa/Utils/auth_interceptor.dart';
import 'package:provider/provider.dart';

// Import your BLoC, Repositories, Services
import 'package:pfa/BLoc/Login/login_bloc.dart';
import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/Services/login_service.dart';

// NEW IMPORTS FOR INTERNSHIPS
import 'package:pfa/Cubit/internship_cubit.dart'; // Import your InternshipCubit
import 'package:pfa/Repositories/internship_repo.dart'; // Import your InternshipRepository

// Import your Screens - adjust paths as per your project
import 'package:pfa/Screens/login.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_home.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_details_page.dart';
import 'package:pfa/Screens/Encadrant/encadrant_home.dart';
import 'package:pfa/Screens/Encadrant/encadrant_profile_page.dart';

// This is the main entry point of your Flutter application.
void main() {
  runApp(const MyApp());
}

// Global variable for GoRouter instance. It will be initialized in MyApp's initState.
late final GoRouter _router;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LoginService _loginService;
  late final LoginRepository _loginRepository;
  late final Dio _dio; // Declare your Dio instance

  // Declare InternshipRepository
  late final InternshipRepository _internshipRepository;

  @override
  void initState() {
    super.initState();

    // --- CONFIGURE AND INITIALIZE DIO ---
    _dio =
        Dio(
            BaseOptions(
              // IMPORTANT: Set your backend base URL correctly for your platform:
              // - Android Emulator: 'http://10.0.2.2/backend'
              // - iOS Simulator/Physical Device: 'http://<YOUR_LOCAL_IP_ADDRESS>/backend'
              // - Flutter Web: 'http://localhost/backend'
              baseUrl:
                  'http://localhost/backend/', // <--- REPLACE THIS WITH YOUR ACTUAL BASE URL
              connectTimeout: const Duration(seconds: 10), // Increased timeout
              receiveTimeout: const Duration(seconds: 10), // Increased timeout
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          )
          ..interceptors.add(
            AuthInterceptor(),
          ) // Add your custom JWT interceptor
          ..interceptors.add(
            LogInterceptor(responseBody: true, requestBody: true),
          ); // For debugging HTTP calls

    // Initialize Login related services/repos, passing the configured Dio instance
    _loginService = LoginService(dio: _dio); // Pass the configured Dio instance
    _loginRepository = LoginRepository(loginService: _loginService);

    // Initialize InternshipRepository, passing the configured Dio instance
    _internshipRepository = InternshipRepository(dio: _dio);

    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: _loginRepository,
      redirect: (BuildContext context, GoRouterState state) async {
        debugPrint(
          'GoRouter Redirect: Evaluating for path: ${state.matchedLocation}',
        );

        final bool loggedIn = await _loginRepository.getToken() != null;
        debugPrint('GoRouter Redirect: Logged In Status: $loggedIn');

        final String? currentUserRole = await _loginRepository
            .getUserRoleFromToken();
        debugPrint('GoRouter Redirect: Current User Role: $currentUserRole');

        final String location = state.matchedLocation;
        final bool tryingToLogin = location == '/login';
        final bool tryingToSplash = location == '/';

        // --- AUTHENTICATION LOGIC ---
        if (!loggedIn) {
          debugPrint('GoRouter Redirect: User NOT logged in.');
          if (tryingToLogin || tryingToSplash) {
            debugPrint('GoRouter Redirect: Allowing access to login/splash.');
            return null; // Allow access to login/splash
          } else {
            debugPrint(
              'GoRouter Redirect: Redirecting to /login (not logged in).',
            );
            return '/login'; // Redirect to login
          }
        }

        // 2. If logged in:
        debugPrint('GoRouter Redirect: User IS logged in.');
        if (tryingToLogin || tryingToSplash) {
          if (currentUserRole == 'Gestionnaire') {
            debugPrint(
              'GoRouter Redirect: Logged in, trying to login/splash. Redirecting to /gestionnaire/home.',
            );
            return '/gestionnaire/home';
          } else if (currentUserRole == 'Encadrant') {
            debugPrint(
              'GoRouter Redirect: Logged in, trying to login/splash. Redirecting to /encadrant/home.',
            );
            return '/encadrant/home';
          }
          debugPrint(
            'GoRouter Redirect: Logged in, but unknown role. Logging out and redirecting to /login.',
          );
          await _loginRepository.deleteToken();
          return '/login';
        }

        // --- AUTHORIZATION LOGIC (Role-based access) ---
        if (currentUserRole == 'Gestionnaire') {
          if (location.startsWith('/encadrant')) {
            debugPrint(
              'GoRouter Redirect: Gestionnaire trying to access Encadrant route. Redirecting to /gestionnaire/home.',
            );
            return '/gestionnaire/home';
          }
        } else if (currentUserRole == 'Encadrant') {
          if (location.startsWith('/gestionnaire')) {
            debugPrint(
              'GoRouter Redirect: Encadrant trying to access Gestionnaire route. Redirecting to /encadrant/home.',
            );
            return '/encadrant/home';
          }
        } else {
          debugPrint(
            'GoRouter Redirect: Authorization check: User has unhandled role ($currentUserRole). Logging out.',
          );
          await _loginRepository.deleteToken();
          return '/login';
        }

        debugPrint(
          'GoRouter Redirect: No redirect needed. Continuing to $location.',
        );
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
        GoRoute(
          path: '/gestionnaire/home',
          builder: (BuildContext context, GoRouterState state) => BlocProvider(
            create: (context) =>
                InternshipCubit(_internshipRepository)..fetchInternships(),
            child: const GestionnaireHome(),
          ),
          routes: <RouteBase>[
            GoRoute(
              path: 'details',
              builder: (BuildContext context, GoRouterState state) =>
                  const GestionnaireDetailsPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/encadrant/home',
          builder: (BuildContext context, GoRouterState state) =>
              const EncadrantHome(),
          routes: <RouteBase>[
            GoRoute(
              path: 'profile',
              builder: (BuildContext context, GoRouterState state) =>
                  const EncadrantProfilePage(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _loginRepository.dispose();
    // Dio instance generally doesn't need explicit dispose unless managing custom adapters.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(loginRepository: _loginRepository),
        ),
        ChangeNotifierProvider<LoginRepository>.value(value: _loginRepository),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
