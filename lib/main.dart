import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pfa/Utils/auth_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pfa/Utils/l10n/app_localizations.dart';

//* Repositories
import 'package:pfa/BLoc/Login/login_bloc.dart';
import 'package:pfa/Services/login_service.dart';
import 'package:pfa/Repositories/login_repo.dart';
import 'package:pfa/Repositories/internship_repo.dart';
import 'package:pfa/repositories/student_repo.dart';
import 'package:pfa/repositories/user_repo.dart';
import 'package:pfa/Repositories/subject_repo.dart';
import 'package:pfa/Repositories/chef_repo.dart';
import 'package:pfa/Repositories/encadrant_repo.dart';
import 'package:pfa/Repositories/stats_repo.dart';

//* Cubit
import 'package:pfa/cubit/internship_cubit.dart';
import 'package:pfa/cubit/user_cubit.dart';
import 'package:pfa/cubit/chef_cubit.dart';
import 'package:pfa/cubit/encadrant_cubit.dart';
import 'package:pfa/cubit/stats_cubit.dart';
import 'package:pfa/cubit/subject_cubit.dart';

// NEW: Import the LocaleProvider
import 'package:pfa/Utils/locale_provider.dart';

//* Screens
import 'package:pfa/Screens/login.dart';
import 'package:pfa/Screens/Gestionnaire/gestionnaire_home.dart';
import 'package:pfa/Screens/Encadrant/encadrant_home.dart';
import 'package:pfa/Screens/ChefCentreInformatique/chef_home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
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
  late final EncadrantRepository encadrantRepository;
  late final ChefCentreRepository chefCentreRepository;
  late final StatsRepository statsRepository;
  late final StudentRepository studentRepository;

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
    userRepository = UserRepository(dio: dio);
    internshipRepository = InternshipRepository(dio: dio);
    subjectRepository = SubjectRepository(dio: dio);
    encadrantRepository = EncadrantRepository(dio: dio);
    chefCentreRepository = ChefCentreRepository(dio: dio);
    statsRepository = StatsRepository(dio: dio);
    studentRepository = StudentRepository(dio: dio);

    //_setDevToken(); // Uncomment if you use this for development tokens

    //* Router
    router = GoRouter(
      initialLocation: '/login', // Set initial location directly to login
      refreshListenable: loginRepository,
      redirect: (BuildContext context, GoRouterState state) async {
        final bool loggedIn = await loginRepository.getToken() != null;
        debugPrint('GoRouter Redirect: Logged In Status: $loggedIn');
        final String? currentUserRole = await loginRepository
            .getUserRoleFromToken();
        debugPrint('GoRouter Redirect: Current User Role: $currentUserRole');

        final String location = state.matchedLocation;
        final bool tryingToLogin = location == '/login';

        // If not logged in
        if (!loggedIn) {
          debugPrint('GoRouter Redirect: User NOT logged in.');
          if (tryingToLogin) {
            debugPrint('GoRouter Redirect: Allowing access to login.');
            return null; // Allow access to login if not logged in
          } else {
            debugPrint(
              'GoRouter Redirect: Redirecting to /login (not logged in, trying protected route).',
            );
            return '/login'; // Redirect to login for any other route
          }
        }

        // If logged in
        debugPrint('GoRouter Redirect: User IS logged in.');
        if (tryingToLogin) {
          // If logged in and trying to access the login page, redirect to home based on role
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

        // Role-based access control for other routes (if already on a non-login route)
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
        return null; // No redirect needed, allow access to current location
      },
      routes: <RouteBase>[
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
              MultiBlocProvider(
                providers: [
                  BlocProvider<EncadrantCubit>(
                    create: (context) =>
                        EncadrantCubit(context.read<EncadrantRepository>()),
                  ),
                  BlocProvider<SubjectCubit>(
                    create: (context) =>
                        SubjectCubit(context.read<SubjectRepository>()),
                  ),
                ],
                child: const EncadrantHome(),
              ),
        ),
        GoRoute(
          path: '/ChefCentreInformatique/home',
          builder: (BuildContext context, GoRouterState state) =>
              const ChefHome(),
        ),
      ],
    );
  }

  void _setDevToken() async {
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      const String devToken =
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3NTI3Mzc5OTAsImV4cCI6MTc1MzM0Mjc5MCwiZGF0YSI6eyJ1c2VySUQiOjEsInVzZXJuYW1lIjoiZ2VzdGlvbm5haXJlIiwicm9sZSI6Ikdlc3Rpb25uYWlyZSJ9fQ.k9s5rMp5-dRAUWwNbOdV-P0YfV3AjOuG_AwJBrP9Ldk'; // Replace with YOUR token

      await prefs.setString('jwt_token', devToken);
      debugPrint('Development token set in SharedPreferences.');

      await loginRepository.setToken(devToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StudentRepository>(
          create: (context) => StudentRepository(dio: dio),
        ),
        RepositoryProvider<SubjectRepository>(
          create: (context) => SubjectRepository(dio: dio),
        ),
        RepositoryProvider<InternshipRepository>(
          create: (context) => InternshipRepository(dio: dio),
        ),
        RepositoryProvider<EncadrantRepository>(
          create: (context) => EncadrantRepository(dio: dio),
        ),
        RepositoryProvider<ChefCentreRepository>(
          create: (context) => ChefCentreRepository(dio: dio),
        ),
        RepositoryProvider<StatsRepository>(
          create: (context) => StatsRepository(dio: dio),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(dio: dio),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(loginRepository: loginRepository),
          ),
          ChangeNotifierProvider<LoginRepository>.value(value: loginRepository),
          // NEW: Provide LocaleProvider
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
          BlocProvider(
            create: (context) => GestionnaireStatsCubit(
              RepositoryProvider.of<StatsRepository>(context),
            ),
          ),
          BlocProvider<EncadrantCubit>(
            create: (context) => EncadrantCubit(
              RepositoryProvider.of<EncadrantRepository>(context),
            ),
          ),
          BlocProvider<SubjectCubit>(
            create: (context) =>
                SubjectCubit(RepositoryProvider.of<SubjectRepository>(context)),
          ),
        ],
        child: Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            return MaterialApp.router(
              locale: localeProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English
                Locale('fr', ''), // French
              ],
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
