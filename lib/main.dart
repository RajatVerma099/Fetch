import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/database/database.dart';
import 'core/scanner/scanner_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/permission_utils.dart';

import 'features/home/bloc/home_bloc.dart';
import 'features/home/screens/home_screen.dart';
import 'features/scan/bloc/scan_bloc.dart';
import 'features/scan/screens/scan_screen.dart';
import 'features/results/bloc/results_bloc.dart';
import 'features/results/screens/results_screen.dart';
import 'features/preview/screens/preview_screen.dart';
import 'features/settings/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  final database = AppDatabase();
  final scannerService = ScannerService();

  runApp(FetchApp(
    database: database,
    scannerService: scannerService,
  ));
}

class FetchApp extends StatefulWidget {
  final AppDatabase database;
  final ScannerService scannerService;

  const FetchApp({
    super.key,
    required this.database,
    required this.scannerService,
  });

  @override
  State<FetchApp> createState() => _FetchAppState();
}

class _FetchAppState extends State<FetchApp> {
  late final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: '/preview/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PreviewScreen(fileId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    // Request permissions on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  Future<void> _requestPermissions() async {
    final hasPermission = await PermissionUtils.hasStoragePermissions();
    if (!hasPermission && mounted) {
      await PermissionUtils.requestStoragePermissions(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.database),
        RepositoryProvider.value(value: widget.scannerService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc(
              scannerService: widget.scannerService,
              database: widget.database,
            )..add(LoadHomeData(context)),
          ),
          BlocProvider(
            create: (context) => ScanBloc(
              scannerService: widget.scannerService,
              database: widget.database,
            ),
          ),
          BlocProvider(
            create: (context) => ResultsBloc(database: widget.database),
          ),
        ],
        child: MaterialApp.router(
          title: 'Fetch',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.system,
          routerConfig: _router,
          builder: (context, child) => _BackButtonHandler(child: child!),
        ),
      ),
    );
  }
}

/// Custom back button handler that prevents immediate app exit
class _BackButtonHandler extends StatefulWidget {
  final Widget child;

  const _BackButtonHandler({required this.child});

  @override
  State<_BackButtonHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<_BackButtonHandler> {
  DateTime? _lastBackPressTime;

  Future<bool> _onWillPop(BuildContext context) async {
    // Get the router to check if we're on root
    final router = GoRouter.of(context);
    final currentRoute = router.routeInformationProvider.value.uri.toString();

    // If we're NOT on the root screen, simply pop to go back
    if (currentRoute != '/') {
      if (context.canPop()) {
        context.pop();
        return false;
      }
    }

    // If we're on the root/home screen, show exit confirmation dialog
    if (currentRoute == '/') {
      final shouldExit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Exit Fetch?'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Exit'),
              ),
            ],
          );
        },
      );

      return shouldExit ?? false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await _onWillPop(context);
          if (shouldExit && mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: widget.child,
    );
  }
}
