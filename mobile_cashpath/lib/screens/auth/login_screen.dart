import 'package:flutter/material.dart';
import 'package:mobile_cashpath/screens/home/home_screen.dart';
import 'package:mobile_cashpath/screens/auth/register_screen.dart';
import 'package:mobile_cashpath/core/services/auth_service.dart';
import 'package:mobile_cashpath/widgets/custom_button.dart';
import 'package:mobile_cashpath/widgets/input_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  void _loginUser() async {
    setState(() {
      isLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // ✅ Call Auth Service for login
    final result = await AuthService.loginUser(email, password, true);

    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid email or password")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark Theme
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              duration: Duration(milliseconds: 800),
              child: Text(
                "Welcome Back!",
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 5),
            FadeInDown(
              duration: Duration(milliseconds: 1000),
              child: Text(
                "Log in to continue",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
            ),
            SizedBox(height: 30),

            // ✅ Email Input
            FadeInLeft(
              duration: Duration(milliseconds: 1000),
              child: InputField(
                controller: emailController,
                hintText: "Enter your email",
                icon: Icons.email,
                color: Colors.greenAccent, // Green highlight
              ),
            ),
            SizedBox(height: 15),

            // ✅ Password Input
            FadeInRight(
              duration: Duration(milliseconds: 1200),
              child: InputField(
                controller: passwordController,
                hintText: "Enter your password",
                icon: Icons.lock,
                obscureText: !isPasswordVisible,
                color: Colors.greenAccent,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.greenAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // ✅ Login Button with Animation
            FadeInUp(
              duration: Duration(milliseconds: 1400),
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                  : CustomButton(
                text: "Login",
                onPressed: _loginUser,
                color: Colors.greenAccent,
              ),
            ),

            SizedBox(height: 20),

            // ✅ Register Link
            FadeInUp(
              duration: Duration(milliseconds: 1600),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register",
                    style: GoogleFonts.montserrat(
                      color: Colors.greenAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
