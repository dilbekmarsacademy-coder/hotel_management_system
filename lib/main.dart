import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_config.dart';
import 'data/services/firebase_bootstrap.dart';
import 'routing/app_router.dart';
import 'core/utils/crash_reporter.dart';
import 'core/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installFlutterErrorHandlers();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final firebaseReady = await FirebaseBootstrap.init();
  AppConfig.logMode();
  AppLogger.i(
    firebaseReady
        ? 'Running in FIREBASE mode (data=${AppConfig.useFirebaseDataEffective})'
        : 'Running in DEMO mode (DummyData)',
    tag: 'Bootstrap',
  );

  runApp(
    const ProviderScope(
      child: HotelManagementApp(),
    ),
  );
}

class HotelManagementApp extends ConsumerWidget {
  const HotelManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'LuxeStay - Grand Luxe Hotel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
