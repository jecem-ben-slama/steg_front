// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Make sure this is imported

// Import your BLoC, Repositories, Services
import 'package:pfa/BLoc/Login/login_bloc.dart';
import 'package:pfa/Repositories/login_repo.dart'; // Your renamed repository
import 'package:pfa/Services/login_service.dart'; // Your renamed service

// Import your Screens - adjust paths as per your project
import 'package:pfa/Screens/login.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_home.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_details_page.dart'; // You MUST create this page or adapt its path
import 'package:pfa/Screens/Encadrant/encadrant_home.dart';
import 'package:pfa/Screens/Encadrant/encadrant_profile_page.dart'; // You MUST create this page or adapt its path
// Add other screens as needed for different roles (e.g., another_role_home.dart)

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
  // Initialize services and repositories once in initState
  late final LoginService _loginService;
  late final LoginRepository _loginRepository;

  @override
  void initState() {
    super.initState();
    _loginService = LoginService();
    _loginRepository = LoginRepository(loginService: _loginService);

    // Initialize GoRouter
    _router = GoRouter(
      // The initial location when the app starts. The redirect will handle where it actually goes.
     initialLocation: '/login',
      // refreshListenable: When _loginRepository (which is a ChangeNotifier) calls notifyListeners(),
      // the redirect function below will be re-evaluated. This is crucial for reacting to login/logout.
      refreshListenable: _loginRepository,
      // This is the core of authentication and authorization logic for navigation.
     redirect: (BuildContext context, GoRouterState state) async {
        print(
          'GoRouter Redirect: Evaluating for path: ${state.matchedLocation}',
        );

        final bool loggedIn = await _loginRepository.getToken() != null;
        print('GoRouter Redirect: Logged In Status: $loggedIn');

        final String? currentUserRole = await _loginRepository
            .getUserRoleFromToken();
        debugPrint('GoRouter Redirect: Current User Role: $currentUserRole');

        final String location = state.matchedLocation;
        final bool tryingToLogin = location == '/login';
        final bool tryingToSplash = location == '/';

        // --- AUTHENTICATION LOGIC ---
        if (!loggedIn) {
          print('GoRouter Redirect: User NOT logged in.');
          if (tryingToLogin || tryingToSplash) {
            print('GoRouter Redirect: Allowing access to login/splash.');
            return null; // Allow access to login/splash
          } else {
            print('GoRouter Redirect: Redirecting to /login (not logged in).');
            return '/login'; // Redirect to login
          }
        }

        // 2. If logged in:
        print('GoRouter Redirect: User IS logged in.');
        if (tryingToLogin || tryingToSplash) {
          if (currentUserRole == 'Gestionnaire') {
            print(
              'GoRouter Redirect: Logged in, trying to login/splash. Redirecting to /gestionnaire/home.',
            );
            return '/gestionnaire/home';
          } else if (currentUserRole == 'Encadrant') {
            print(
              'GoRouter Redirect: Logged in, trying to login/splash. Redirecting to /encadrant/home.',
            );
            return '/encadrant/home';
          }
          print(
            'GoRouter Redirect: Logged in, but unknown role. Logging out and redirecting to /login.',
          );
          await _loginRepository.deleteToken();
          return '/login';
        }

        // --- AUTHORIZATION LOGIC (Role-based access) ---
        // This section is what determines if they stay on the current page or are redirected.
        if (currentUserRole == 'Gestionnaire') {
          if (location.startsWith('/encadrant')) {
            print(
              'GoRouter Redirect: Gestionnaire trying to access Encadrant route. Redirecting to /gestionnaire/home.',
            );
            return '/gestionnaire/home';
          }
        } else if (currentUserRole == 'Encadrant') {
          if (location.startsWith('/gestionnaire')) {
            print(
              'GoRouter Redirect: Encadrant trying to access Gestionnaire route. Redirecting to /encadrant/home.',
            );
            return '/encadrant/home';
          }
        } else {
          print(
            'GoRouter Redirect: Authorization check: User has unhandled role ($currentUserRole). Logging out.',
          );
          await _loginRepository.deleteToken();
          return '/login';
        }

        print(
          'GoRouter Redirect: No redirect needed. Continuing to $location.',
        );
        return null; // This is the key: if no other 'return' is hit, stay on current page.
      }, // Define all your application's routes
      routes: <RouteBase>[
        // The root '/' will be handled by redirect and typically serves as a temporary loading screen
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ), // Simple Splash screen
        ),
        // Login Route
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
        // --- Gestionnaire Routes ---
        // A top-level route for Gestionnaire's area
        GoRoute(
          path: '/gestionnaire/home', // This is the base route for Gestionnaire
          builder: (BuildContext context, GoRouterState state) =>
              const GestionnaireHome(),
          routes: <RouteBase>[
            // Nested routes under /gestionnaire/home
            GoRoute(
              path: 'details', // Full path: /gestionnaire/home/details
              builder: (BuildContext context, GoRouterState state) =>
                  const GestionnaireDetailsPage(),
            ),
            // Add other Gestionnaire nested routes here (e.g., 'reports', 'settings')
          ],
        ),
        // --- Encadrant Routes ---
        GoRoute(
          path: '/encadrant/home', // Base route for Encadrant
          builder: (BuildContext context, GoRouterState state) =>
              const EncadrantHome(),
          routes: <RouteBase>[
            GoRoute(
              path: 'profile', // Full path: /encadrant/home/profile
              builder: (BuildContext context, GoRouterState state) =>
                  const EncadrantProfilePage(),
            ),
            // Add other Encadrant nested routes here
          ],
        ),
        // Add other user role base routes here (e.g., /admin/home)
      ],
      // Optional: For Flutter Web, consider UrlPathStrategy.hashPlatformStrategy
      // This makes URLs like example.com/#/home instead of example.com/home
      // This is often preferred for web to avoid server-side routing issues if
      // your web server isn't configured for HTML5 pushState.
      // urlPathStrategy: UrlPathStrategy.hashPlatformStrategy,
    );
  }

  @override
  void dispose() {
    // Dispose the repository to prevent memory leaks if it's a ChangeNotifier
    _loginRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(loginRepository: _loginRepository),
        ),
        // Provide LoginRepository as a ChangeNotifierProvider so it can notify listeners
        ChangeNotifierProvider<LoginRepository>.value(value: _loginRepository),
        // Add any other top-level providers here
      ],
      // Use MaterialApp.router for GoRouter integration
      child: MaterialApp.router(
        routerConfig: _router, // Pass the GoRouter instance here
        debugShowCheckedModeBanner: false,
        
      ),
    );
  }
}
