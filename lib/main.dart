// lib/main.dart
import 'package:geziyorum/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:geziyorum/screens/home_screen.dart';
import 'package:geziyorum/screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:geziyorum/services/auth_service.dart';
import 'package:geziyorum/services/favorite_service.dart';
import 'package:geziyorum/screens/auth/login_screen.dart'; // LoginScreen import edildi
import 'package:geziyorum/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('tr', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FavoriteService(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthService(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserDataService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class AppColors {
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF8BC34A);
  static const Color secondaryAccentColor = Color(0xFFFFC107);
  static const Color textColor = Color(0xFF212121);
  static const Color lightTextColor = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color lightGray = Color(0xFFF5F5F5);
}

ThemeData appTheme() {
  return ThemeData(
    primaryColor: AppColors.primaryColor,
    hintColor: AppColors.accentColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    appBarTheme: const AppBarTheme(
      color: AppColors.primaryColor,
      iconTheme: IconThemeData(color: AppColors.white),
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: AppColors.textColor),
      titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic, color: AppColors.textColor),
      bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: AppColors.textColor),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      hintStyle: TextStyle(color: AppColors.lightTextColor),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return MaterialApp(
      title: 'Geziyorum',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: StreamBuilder(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            return MainScreen(key: mainScreenKey);
          } else {
            // DÜZELTME: Kullanıcı oturum açmamışsa LoginScreen'e yönlendiriliyor
            return const LoginScreen();
          }
        },
      ),
    );
  }
}