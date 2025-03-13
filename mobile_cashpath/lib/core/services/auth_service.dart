import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_cashpath/config/api_endpoints.dart';

class AuthService {
  static final _storage = FlutterSecureStorage();

  // ✅ Register User
  static Future<Map<String, dynamic>?> registerUser(
      String name, String email, String password, String passwordConfirm,
      String? profilePicture, String currency, String language, String timezone) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirm,
        "profile_picture": profilePicture ?? "",
        "currency": currency,
        "language": language,
        "timezone": timezone
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }


  static Future<bool> updateProfile({
    required String name,
    required String currency,
    required String language,
    required String timezone,
  }) async {
    final token = await _storage.read(key: "auth_token");

    final response = await http.put(
      Uri.parse(ApiEndpoints.updateProfile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "name": name,
        "currency": currency,
        "language": language,
        "timezone": timezone,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> updatePassword(String currentPassword, String newPassword) async {
    final token = await _storage.read(key: "auth_token");

    final response = await http.put(
      Uri.parse(ApiEndpoints.updatePassword),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "current_password": currentPassword,
        "new_password": newPassword,
        "new_password_confirmation": newPassword,
      }),
    );

    return response.statusCode == 200;
  }



  // ✅ Login User
  static Future<Map<String, dynamic>?> loginUser(String email, String password, bool rememberMe) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "remember_me": rememberMe,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: "auth_token", value: data['token']);
      return data;
    } else {
      return null;
    }
  }

  // ✅ Logout User
  static Future<void> logoutUser() async {
    final token = await _storage.read(key: "auth_token");

    await http.post(
      Uri.parse(ApiEndpoints.logout),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    await _storage.delete(key: "auth_token");
  }

  // ✅ Get User Profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await _storage.read(key: "auth_token");

    final response = await http.get(
      Uri.parse(ApiEndpoints.userProfile),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
  // ✅ Get Auth Token
  static Future<String?> getToken() async {
    return await _storage.read(key: "auth_token");
  }


  // ✅ Get Authenticated User ID
  static Future<String?> getUserId() async {
    final token = await _storage.read(key: "auth_token");
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(ApiEndpoints.userProfile), // Ensure this API returns user data
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user']['id'].toString(); // ✅ Ensure ID is returned as a String
    } else {
      return null;
    }
  }

}


