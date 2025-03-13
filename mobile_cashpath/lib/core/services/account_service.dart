import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_cashpath/config/api_endpoints.dart';
import 'package:mobile_cashpath/models/account_model.dart';

class AccountService {
  final String baseUrl = ApiEndpoints.BASE_URL;

  // ✅ Get all accounts for the authenticated user
  Future<List<Account>> getAccounts(String token) async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.accounts),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['accounts'];
      return data.map((e) => Account.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load accounts");
    }
  }

  // ✅ Fetch total balance
  Future<double> getTotalBalance(String token) async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.totalBalance),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body)['total_balance'];
      return double.tryParse(data.toString()) ?? 0.0; // ✅ FIX: Ensure it's always a double
    } else {
      throw Exception("Failed to fetch total balance");
    }
  }

  // ✅ Create a new account
  Future<bool> createAccount(String token, Account account) async {
    final response = await http.post(
      Uri.parse(ApiEndpoints.accounts),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(account.toJson()),
    );

    return response.statusCode == 201;
  }

  // ✅ Update an account
  Future<bool> updateAccount(String token, String id, Account account) async {
    final response = await http.put(
      Uri.parse(ApiEndpoints.accountDetails(id)),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(account.toJson()),
    );

    return response.statusCode == 200;
  }

  // ✅ Delete an account
  Future<bool> deleteAccount(String token, String id) async {
    final response = await http.delete(
      Uri.parse(ApiEndpoints.accountDetails(id)),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }

  // ✅ Set an account as default
  Future<bool> setDefaultAccount(String token, String id) async {
    final response = await http.patch(
      Uri.parse(ApiEndpoints.setDefaultAccount(id)),
      headers: {"Authorization": "Bearer $token"},
    );

    return response.statusCode == 200;
  }
}
