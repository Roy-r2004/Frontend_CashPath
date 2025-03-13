import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_cashpath/screens/auth/login_screen.dart';
import 'package:mobile_cashpath/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final _storage = FlutterSecureStorage();
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // **Fade & Scale Animations**
    _fadeController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _scaleController = AnimationController(vsync: this, duration: Duration(seconds: 2));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    _checkLogin();
  }

  void _checkLogin() async {
    final token = await _storage.read(key: "auth_token");

    Future.delayed(Duration(seconds: 3), () {
      if (token != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // **Netflix-style black background**
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // **Biggest Logo Possible**
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'lib/assets/images/logo.png', // ✅ Path to your logo
                  width: 280, // **Much Bigger Logo**
                  height: 280,
                ),
              ),
            ),

            SizedBox(height: 30),

            // **Premium Loading Indicator**
            FadeTransition(
              opacity: _fadeAnimation,
              child: CircularProgressIndicator(
                color: Colors.white, // ✅ Matches Netflix elegance
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
