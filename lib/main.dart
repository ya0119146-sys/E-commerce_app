import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/localization/locale_cubit.dart';
import 'core/di/service_locator.dart';
import 'app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handlers for production stability and diagnostics
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught platform error: $error');
    return true;
  };

  // Safely load environment variables, fallback gracefully to production constants
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(
      'Warning: .env failed to load, falling back to ApiConstants defaults: $e',
    );
  }

  // Pre-load saved language synchronously so all interceptors & errors have it immediately
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('labella_language_code');
    if (savedLang != null && (savedLang == 'ar' || savedLang == 'en')) {
      LocaleCubit.currentLanguage = savedLang;
    }
  } catch (_) {}

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

  // Initialize dependency injection
  await setupServiceLocator();

  runApp(const ECommerceApp());
}
