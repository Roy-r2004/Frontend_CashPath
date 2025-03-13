import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final _storage = FlutterSecureStorage();
  static const String BASE_URL = "http://127.0.0.1:8000/api";

  static Future<Map<String, dynamic>?> get(String endpoint) async {
    final token = await _storage.read(key: "auth_token");
    final response = await http.get(
      Uri.parse("$BASE_URL$endpoint"),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  static Future<void> patch(String endpoint) async {
    final token = await _storage.read(key: "auth_token");
    await http.patch(
      Uri.parse("$BASE_URL$endpoint"),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<void> delete(String endpoint) async {
    final token = await _storage.read(key: "auth_token");
    await http.delete(
      Uri.parse("$BASE_URL$endpoint"),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
