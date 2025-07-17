import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pfa/Utils/auth_interceptor.dart';
import 'package:provider/provider.dart';
//* Login
import 'package:pfa/BLoc/Login/login_bloc.dart';
import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/Services/login_service.dart';

//* Internship
import 'package:pfa/Cubit/internship_cubit.dart';
import 'package:pfa/Repositories/internship_repo.dart';

//* Screens
import 'package:pfa/Screens/login.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_home.dart';
// import 'package:pfa/Screens/Gestionnaire/gestionnaire_details_page.dart'; // No longer directly used as a route if we embed content
import 'package:pfa/Screens/Encadrant/encadrant_home.dart';
import 'package:pfa/Screens/Encadrant/encadrant_profile_page.dart';
import 'package:pfa/Screens/ChefCentreInformatique/chef_home.dart';

void main() {
  runApp(const MyApp());
}

late final GoRouter router;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LoginService loginService;
  late final LoginRepository loginRepository;
  late final Dio dio;
  late final InternshipRepository internshipRepository;

  @override
  void initState() {
    super.initState();

    dio =
        Dio(
            BaseOptions(
              baseUrl: 'http://localhost/backend/',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          )
          ..interceptors.add(AuthInterceptor())
          ..interceptors.add(
            LogInterceptor(responseBody: true, requestBody: true),
          );
    loginService = LoginService(dio: dio);
    loginRepository = LoginRepository(loginService: loginService);

    internshipRepository = InternshipRepository(dio: dio);
    //* Router
    router = GoRouter(
      initialLocation: '/login',
      refreshListenable: loginRepository,
      redirect: (BuildContext context, GoRouterState state) async {
        final bool loggedIn = await loginRepository.getToken() != null;
        debugPrint('GoRouter Redirect: Logged In Status: $loggedIn');
        final String? currentUserRole = await loginRepository
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
            return null;
          } else {
            debugPrint(
              'GoRouter Redirect: Redirecting to /login (not logged in).',
            );
            return '/login';
          }
        }

        // 2. If logged in:
        debugPrint('GoRouter Redirect: User IS logged in.');
        if (tryingToLogin || tryingToSplash) {
          if (currentUserRole == 'Gestionnaire') {
            return '/gestionnaire/home';
          } else if (currentUserRole == 'Encadrant') {
            return '/encadrant/home';
          } else if (currentUserRole == "ChefCentreInformatique") {
            return '/ChefCentreInformatique/home';
          }
          debugPrint(
            'GoRouter Redirect: Logged in, but unknown role. Logging out and redirecting to /login.',
          );
          await loginRepository.deleteToken();
          return '/login';
        }
        //!!! Change this to handle the new role
        // --- AUTHORIZATION LOGIC (Role-based access) ---
        if (currentUserRole == 'Gestionnaire') {
          if (location.startsWith('/encadrant') ||
              location.startsWith('/ChefCentreInformatique')) {
            debugPrint(
              'GoRouter Redirect: Gestionnaire trying to access Encadrant/ChefCentreInformatique route. Redirecting to /gestionnaire/home.',
            );
            return '/gestionnaire/home';
          }
        } else if (currentUserRole == 'Encadrant') {
          if (location.startsWith('/gestionnaire') ||
              location.startsWith('/ChefCentreInformatique')) {
            debugPrint(
              'GoRouter Redirect: Encadrant trying to access Gestionnaire/ChefCentreInformatique route. Redirecting to /encadrant/home.',
            );
            return '/encadrant/home';
          }
        } else if (currentUserRole == 'ChefCentreInformatique') {
          // <--- ADD THIS NEW BLOCK
          if (location.startsWith('/gestionnaire') ||
              location.startsWith('/encadrant')) {
            debugPrint(
              'GoRouter Redirect: ChefCentreInformatique trying to access Gestionnaire/Encadrant route. Redirecting to /ChefCentreInformatique/home.',
            );
            return '/ChefCentreInformatique/home';
          }
        } else {
          debugPrint(
            'GoRouter Redirect: Authorization check: User has unhandled role ($currentUserRole). Logging out.',
          );
          await loginRepository.deleteToken();
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
                InternshipCubit(internshipRepository)
                  ..fetchInternships(), // Cubit is provided here
            child: const GestionnaireHome(), // GestionnaireHome is the child
          ),
         
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
        GoRoute(
          path: '/ChefCentreInformatique/home',
          builder: (BuildContext context, GoRouterState state) =>
              const ChefCentreInformatiqueHome(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(loginRepository: loginRepository),
        ),
        ChangeNotifierProvider<LoginRepository>.value(value: loginRepository),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
