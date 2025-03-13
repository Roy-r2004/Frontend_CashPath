import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_cashpath/core/services/auth_service.dart';
import 'package:mobile_cashpath/screens/auth/login_screen.dart';
import 'package:mobile_cashpath/widgets/custom_button.dart';
import 'package:mobile_cashpath/widgets/input_field.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController timezoneController = TextEditingController();

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String profilePictureUrl = "";
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // ✅ Fetch User Profile
  void _fetchUserProfile() async {
    setState(() => isLoading = true);

    final profile = await AuthService.getUserProfile();
    if (profile != null) {
      setState(() {
        nameController.text = profile['user']['name'];
        currencyController.text = profile['user']['currency'] ?? "USD";
        languageController.text = profile['user']['language'] ?? "en";
        timezoneController.text = profile['user']['timezone'] ?? "UTC";
        profilePictureUrl = profile['user']['profile_picture'] ?? "";
      });
    }

    setState(() => isLoading = false);
  }

  // ✅ Pick Image for Profile
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  // ✅ Update Profile
  void _updateProfile() async {
    setState(() => isLoading = true);

    final success = await AuthService.updateProfile(
      name: nameController.text.trim(),
      currency: currencyController.text.trim(),
      language: languageController.text.trim(),
      timezone: timezoneController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile.")),
      );
    }

    setState(() => isLoading = false);
  }

  // ✅ Update Password
  void _updatePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await AuthService.updatePassword(
      currentPasswordController.text.trim(),
      newPasswordController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password updated successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update password.")),
      );
    }

    setState(() => isLoading = false);
  }

  // ✅ Logout
  void _logout() async {
    await AuthService.logoutUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Profile Picture
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : (profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : AssetImage('assets/images/default_avatar.png')) as ImageProvider,
              ),
            ),
            SizedBox(height: 10),
            Text("Tap to change profile picture", style: TextStyle(color: Colors.white70)),

            SizedBox(height: 20),

            // ✅ Name
            InputField(
              controller: nameController,
              hintText: "Name",
              icon: Icons.person,
            ),

            SizedBox(height: 15),

            // ✅ Currency
            InputField(
              controller: currencyController,
              hintText: "Currency (e.g., USD, EUR)",
              icon: Icons.attach_money,
            ),

            SizedBox(height: 15),

            // ✅ Language
            InputField(
              controller: languageController,
              hintText: "Language (e.g., en, fr)",
              icon: Icons.language,
            ),

            SizedBox(height: 15),

            // ✅ Timezone
            InputField(
              controller: timezoneController,
              hintText: "Timezone",
              icon: Icons.timer,
            ),

            SizedBox(height: 20),

            // ✅ Update Profile Button
            CustomButton(
              text: "Update Profile",
              onPressed: _updateProfile,
            ),

            Divider(color: Colors.white54, thickness: 1, height: 40),

            // ✅ Password Fields
            InputField(
              controller: currentPasswordController,
              hintText: "Current Password",
              icon: Icons.lock,
              obscureText: true,
            ),

            SizedBox(height: 15),

            InputField(
              controller: newPasswordController,
              hintText: "New Password",
              icon: Icons.lock_outline,
              obscureText: true,
            ),

            SizedBox(height: 15),

            InputField(
              controller: confirmPasswordController,
              hintText: "Confirm New Password",
              icon: Icons.lock_outline,
              obscureText: true,
            ),

            SizedBox(height: 20),

            // ✅ Update Password Button
            CustomButton(
              text: "Change Password",
              onPressed: _updatePassword,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
