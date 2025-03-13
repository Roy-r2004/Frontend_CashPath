import 'package:flutter/material.dart';
import 'package:mobile_cashpath/screens/auth/login_screen.dart';
import 'package:mobile_cashpath/screens/auth/register_screen.dart';
import 'package:mobile_cashpath/screens/home/home_screen.dart';
import 'package:mobile_cashpath/screens/splash_screen.dart';
import 'package:mobile_cashpath/routes/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Black fancy theme
      initialRoute: AppRoutes.splash, // Start with Splash Screen
      routes: {
        AppRoutes.splash: (context) => SplashScreen(),
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.register: (context) => RegisterScreen(),
        AppRoutes.home: (context) => HomeScreen(),
      },
    );
  }
}
