/* // lib/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Import all screens, cubits, and repositories used in the router
import 'package:pfa/Cubit/internship_cubit.dart';
import 'package:pfa/Repositories/internship_repo.dart';
import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/Screens/Encadrant/encadrant_home.dart';
import 'package:pfa/Screens/Encadrant/encadrant_profile_page.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_details_page.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_home.dart';
import 'package:pfa/Screens/login.dart';

class AppRouter {
  static GoRouter createRouter({
    required LoginRepository loginRepository,
    required InternshipRepository internshipRepository,
  }) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable:
          loginRepository, // LoginRepository must be a ChangeNotifier
      redirect: (BuildContext context, GoRouterState state) async {
        final bool loggedIn = await loginRepository.getToken() != null;
        final String? currentUserRole = await loginRepository
            .getUserRoleFromToken();
        final String location = state.matchedLocation;
        final bool tryingToLoginOrSplash =
            location == '/login' || location == '/';

        // 1. If not logged in:
        if (!loggedIn) {
          // Allow access to login/splash, otherwise redirect to login
          return tryingToLoginOrSplash ? null : '/login';
        }

        // 2. If logged in:
        //    a. If trying to access login/splash, redirect to appropriate home page based on role
        if (tryingToLoginOrSplash) {
          if (currentUserRole == 'Gestionnaire') {
            return '/gestionnaire/home';
          } else if (currentUserRole == 'Encadrant') {
            return '/encadrant/home';
          }
          // If role is unknown/null while logged in and trying to access login/splash
          await loginRepository.deleteToken(); // Force logout for unknown role
          return '/login';
        }

        // 3. Authorization Logic (Role-based access)
        //    Ensure users can only access their allowed routes.
        if (currentUserRole == 'Gestionnaire') {
          if (location.startsWith('/encadrant')) {
            return '/gestionnaire/home'; // Gestionnaire cannot access Encadrant routes
          }
        } else if (currentUserRole == 'Encadrant') {
          if (location.startsWith('/gestionnaire')) {
            return '/encadrant/home'; // Encadrant cannot access Gestionnaire routes
          }
        } else {
          // Unhandled role for any other authenticated route, log out.
          await loginRepository.deleteToken();
          return '/login';
        }

        // 4. No redirect needed, allow access to the requested location
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
        // Grouped routes under their main role path for better organization
        GoRoute(
          path: '/gestionnaire', // Parent route for gestionnaire
          routes: <RouteBase>[
            GoRoute(
              path: 'home', // full path: /gestionnaire/home
              builder: (BuildContext context, GoRouterState state) =>
                  BlocProvider(
                    create: (context) =>
                        InternshipCubit(internshipRepository)
                          ..fetchInternships(),
                    child: const GestionnaireHome(),
                  ),
              routes: <RouteBase>[
                GoRoute(
                  path: 'details', // full path: /gestionnaire/home/details
                  builder: (BuildContext context, GoRouterState state) =>
                      const GestionnaireMainContent(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/encadrant', 
          routes: <RouteBase>[
            GoRoute(
              path: 'home', // full path: /encadrant/home
              builder: (BuildContext context, GoRouterState state) =>
                  const EncadrantHome(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'profile', // full path: /encadrant/home/profile
                  builder: (BuildContext context, GoRouterState state) =>
                      const EncadrantProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
 */