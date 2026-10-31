import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for optimal aesthetic camera feel
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Core Services
  final storageService = await StorageService.init();
  final authService = AuthService();

  runApp(
    AestheticDigicamApp(
      storageService: storageService,
      authService: authService,
    ),
  );
}

class AestheticDigicamApp extends StatelessWidget {
  final StorageService storageService;
  final AuthService authService;

  const AestheticDigicamApp({
    super.key,
    required this.storageService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aesthetic Digicam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: MainNavigationScreen(
        storageService: storageService,
        authService: authService,
      ),
    );
  }
}
