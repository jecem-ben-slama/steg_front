import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pfa/Utils/auth_interceptor.dart';
import 'package:pfa/cubit/chef_cubit.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';
import 'package:provider/provider.dart';
//* Repositories
import 'package:pfa/BLoc/Login/login_bloc.dart';
import 'package:pfa/Services/login_service.dart';
// ↑↑ was coded using the BLoC pattern, which was later changed to Cubit for the rest of the app
import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/Repositories/internship_repo.dart'; //* */
import 'package:pfa/repositories/student_repo.dart';
import 'package:pfa/repositories/user_repo.dart';
import 'package:pfa/repositories/subject_repo.dart';
import 'package:pfa/Repositories/chef_repo.dart';
import 'package:pfa/Repositories/encadrant_repo.dart';

//* Cubit
import 'package:pfa/cubit/internship_cubit.dart';
import 'package:pfa/cubit/user_cubit.dart';

//* Screens
import 'package:pfa/Screens/login.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_home.dart';
import 'package:pfa/Screens/Encadrant/encadrant_home.dart';
import 'package:pfa/Screens/ChefCentreInformatique/chef_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late final UserRepository userRepository;
  late final SubjectRepository subjectRepository;

  @override
  //* Configuration of Dio and Repositories
  void initState() {
    super.initState();
    //? Initialize Dio with base options
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
    //? Initialize Repositories
    loginService = LoginService(dio: dio);
    loginRepository = LoginRepository(loginService: loginService);
    userRepository = UserRepository(dio: dio);
    internshipRepository = InternshipRepository(dio: dio);
    subjectRepository = SubjectRepository(dio: dio);
    _setDevToken();
    //* Router
    //! Move the router initialization to a separate file
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
                InternshipCubit(internshipRepository)..fetchInternships(),
            child: const GestionnaireHome(),
          ),
        ),
        GoRoute(
          path: '/encadrant/home',
          builder: (BuildContext context, GoRouterState state) =>
              const EncadrantHome(),
        ),
        GoRoute(
          path: '/ChefCentreInformatique/home',
          builder: (BuildContext context, GoRouterState state) =>
              const ChefHome(),
        ),
      ],
    );
  }

  //! This function is used to set a development token for testing purposes.
  void _setDevToken() async {
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      //*gestionnaire
      const String devToken =
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NTI3Mzc5OTAsImV4cCI6MTc1MzM0Mjc5MCwiZGF0YSI6eyJ1c2VySUQiOjEsInVzZXJuYW1lIjoiZ2VzdGlvbm5haXJlIiwicm9sZSI6Ikdlc3Rpb25uYWlyZSJ9fQ.k9s5rMp5-dRAUWwNbOdV-P0YfV3AjOuG_AwJBrP9Ldk'; // Replace with YOUR token

      //*encadrant
      const String devToken1 =
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NTMwMjQ5NjEsImV4cCI6MTc1MzYyOTc2MSwiZGF0YSI6eyJ1c2VySUQiOjUsInVzZXJuYW1lIjoiRW5jYWRyYW50VXBkYXRlZCIsInJvbGUiOiJFbmNhZHJhbnQifX0.bJQJufOTJkBTRA2fEzzb0P7IcIDL_sUMXnnSCm1kh_s";
      //* chef
      const String devToken2 =
          "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NTMwMjQ5MTEsImV4cCI6MTc1MzYyOTcxMSwiZGF0YSI6eyJ1c2VySUQiOjMsInVzZXJuYW1lIjoidGVzdCIsInJvbGUiOiJDaGVmQ2VudHJlSW5mb3JtYXRpcXVlIn19.LKXQ_w6WexprOW8oZqevmZapnHA6JrRlMZlPiwERGyU";

      await prefs.setString('jwt_token', devToken2);
      debugPrint('Development token set in SharedPreferences.');

      await loginRepository.setToken(devToken2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(dio: dio),
        ),
        RepositoryProvider<StudentRepository>(
          create: (context) => StudentRepository(dio: dio),
        ),
        RepositoryProvider<SubjectRepository>(
          // Provide SubjectRepository
          create: (context) => SubjectRepository(dio: dio),
        ),
        RepositoryProvider<InternshipRepository>(
          // Provide InternshipRepository
          create: (context) => InternshipRepository(dio: dio),
        ),
        Provider<EncadrantRepository>(
          create: (context) => EncadrantRepository(dio: dio),
        ),
        // EncadrantCubit depends on EncadrantRepository
        BlocProvider<EncadrantCubit>(
          create: (context) =>
              EncadrantCubit(context.read<EncadrantRepository>()),
        ),
        RepositoryProvider<ChefCentreRepository>(
          create: (context) => ChefCentreRepository(dio: dio),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(loginRepository: loginRepository),
          ),
          ChangeNotifierProvider<LoginRepository>.value(value: loginRepository),
          BlocProvider<InternshipCubit>(
            create: (context) => InternshipCubit(
              RepositoryProvider.of<InternshipRepository>(context),
            ),
          ),
          BlocProvider<UserCubit>(
            create: (context) =>
                UserCubit(RepositoryProvider.of<UserRepository>(context)),
          ),
          BlocProvider<ChefCentreCubit>(
            create: (context) => ChefCentreCubit(
              RepositoryProvider.of<ChefCentreRepository>(context),
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
