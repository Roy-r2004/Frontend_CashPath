import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_cashpath/core/services/auth_service.dart';
import 'package:mobile_cashpath/config/api_endpoints.dart';

class BudgetService {
  // ✅ Create Manual Budget
  Future<bool> createBudget({
    required String categoryId,
    required double amount,
    required String period,
    required String startDate,
    String? endDate,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.post(
      Uri.parse(ApiEndpoints.createBudget),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "category_id": categoryId,
        "amount": amount,
        "period": period,
        "start_date": startDate,
        "end_date": endDate,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("❌ Failed to create budget: ${response.body}");
      return false;
    }
  }

  // ✅ Automatic Allocation with predefined percentages
  Future<bool> autoAllocateBudget(Map<String, double> percentages) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("User not authenticated");

    // Optionally validate the total percent does not exceed 100
    double total = percentages.values.fold(0, (a, b) => a + b);
    if (total > 100.0) {
      print("❌ Percentages exceed 100%");
      return false;
    }

    final response = await http.post(
      Uri.parse(ApiEndpoints.autoAllocateBudget),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"percentages": percentages}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Failed to auto allocate budgets: ${response.body}");
      return false;
    }
  }

  // ✅ Get All Budgets
  Future<List<dynamic>> getBudgets() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse(ApiEndpoints.budgets),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['budgets'] ?? [];
    } else {
      print("❌ Error fetching budgets: ${response.body}");
      throw Exception("Failed to fetch budgets");
    }
  }

  // ✅ Get Budget Summary
  Future<Map<String, dynamic>> getBudgetSummary() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse(ApiEndpoints.budgetSummary),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Error fetching budget summary: ${response.body}");
      throw Exception("Failed to fetch budget summary");
    }
  }

  // ✅ Update Budget
  Future<bool> updateBudget(String id, {double? amount, String? status}) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.put(
      Uri.parse(ApiEndpoints.updateBudget(id)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "amount": amount,
        "status": status,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Failed to update budget: ${response.body}");
      return false;
    }
  }

  // ✅ Delete Budget
  Future<bool> deleteBudget(String id) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.delete(
      Uri.parse(ApiEndpoints.deleteBudget(id)),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Failed to delete budget: ${response.body}");
      return false;
    }
  }
}