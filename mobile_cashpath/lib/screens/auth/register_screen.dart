import 'package:flutter/material.dart';
import 'package:mobile_cashpath/core/services/auth_service.dart';
import 'package:mobile_cashpath/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController currencyController = TextEditingController(text: "USD");
  final TextEditingController languageController = TextEditingController(text: "en");
  final TextEditingController timezoneController = TextEditingController(text: "UTC");

  bool isPasswordVisible = false;
  bool isLoading = false;

  void _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await AuthService.registerUser(
      nameController.text,
      emailController.text,
      passwordController.text,
      confirmPasswordController.text,
      null, // ✅ Removed profile picture upload
      currencyController.text,
      languageController.text,
      timezoneController.text,
    );

    setState(() => isLoading = false);

    if (response != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed!"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // **Dark Premium Theme**
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80),

            // **Animated Header**
            Text(
              "Create Your Account",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            SizedBox(height: 10),
            Text(
              "Start tracking your expenses today",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            SizedBox(height: 40),

            _buildTextField(nameController, "Full Name", Icons.person),
            _buildTextField(emailController, "Email", Icons.email),
            _buildPasswordField(passwordController, "Password"),
            _buildPasswordField(confirmPasswordController, "Confirm Password"),
            _buildTextField(currencyController, "Currency (Default: USD)", Icons.attach_money),
            _buildTextField(languageController, "Language (Default: en)", Icons.language),
            _buildTextField(timezoneController, "Timezone (Default: UTC)", Icons.access_time),
            SizedBox(height: 30),

            // **Register Button**
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: isLoading ? Colors.grey : Colors.greenAccent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isLoading
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                onPressed: isLoading ? null : _register,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : Text("Register", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),

            SizedBox(height: 20),

            // **Login Link**
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: Text(
                "Already have an account? Login",
                style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // **✅ Reusable Input Field**
  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.greenAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // **✅ Enhanced Password Field with Animation**
  Widget _buildPasswordField(TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: !isPasswordVisible,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.lock, color: Colors.greenAccent),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() => isPasswordVisible = !isPasswordVisible);
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white54,
                key: ValueKey<bool>(isPasswordVisible),
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
