import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_cashpath/config/api_endpoints.dart';
import 'package:mobile_cashpath/models/transaction_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_cashpath/models/account_model.dart';
import 'package:mobile_cashpath/models/category_model.dart';
import 'package:mobile_cashpath/core/services/budget_service.dart';

import 'auth_service.dart';

class TransactionService {
  final _storage = const FlutterSecureStorage();

  // ✅ Get Auth Token
  Future<String?> _getToken() async {
    return await _storage.read(key: "auth_token");
  }

  // ✅ Fetch all transactions with optional filters
  Future<List<Transaction>> getTransactions({
    String? type,
    String? categoryId,
    String? startDate,
    String? endDate,
    int perPage = 10,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    Uri uri = Uri.parse(ApiEndpoints.transactions).replace(queryParameters: {
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'per_page': perPage.toString(),
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['transactions']['data'];
      return data.map((e) => Transaction.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load transactions");
    }
  }

  // ✅ Get a single transaction by ID
  Future<Transaction> getTransactionById(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse("${ApiEndpoints.transactions}/$id"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body)['transaction']);
    } else {
      throw Exception("Transaction not found");
    }
  }

  // ✅ Create a new transaction
  Future<bool> createTransaction({
    required String userId,
    required String accountId,
    required String categoryId,
    required double amount,
    required String type,
    required String date,
    required String time,
    String? note,
    required bool isRecurring,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    // ✅ Proceed with transaction creation
    final response = await http.post(
      Uri.parse(ApiEndpoints.transactions),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // Laravel API needs this
        'Authorization': 'Bearer $token', // ✅ Pass the token here
      },
      body: jsonEncode({
        "user_id": userId,
        "account_id": accountId,
        "category_id": categoryId,
        "amount": amount,
        "type": type,
        "date": date,
        "time": time,
        "note": note ?? "",
        "is_recurring": isRecurring,
      }),
    );

    if (response.statusCode == 201) {
      print("✅ Transaction Created Successfully");
      await BudgetService().getBudgets(); // Optional to reload locally
      await BudgetService().getBudgetSummary(); // Optional to reload summary
      return true;
    }else {
      print("❌ Error creating transaction: ${response.body}");
      return false;
    }
  }




  /// ✅ Helper method to update account balance after transaction
  Future<bool> updateAccountBalance(String accountId, double updatedBalance) async {
    final token = await _getToken();
    if (token == null) return false; // ❌ Return false if user is not authenticated

    final response = await http.put(
      Uri.parse("${ApiEndpoints.accounts}/$accountId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"balance": updatedBalance}),
    );

    if (response.statusCode == 200) {
      return true; // ✅ Successfully updated balance
    } else {
      print("❌ Failed to update account balance: ${response.body}");
      return false; // ❌ Return false if update failed
    }
  }




  Future<Map<String, double>> fetchSummary() async {
    final token = await _getToken();
    if (token == null) return {"total_income": 0.0, "total_expenses": 0.0};

    final response = await http.get(
      Uri.parse(ApiEndpoints.transactionSummary),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "total_income": double.tryParse(data['total_income'].toString()) ?? 0.0,
        "total_expenses": double.tryParse(data['total_expenses'].toString()) ?? 0.0,
      };
    } else {
      throw Exception("Failed to load income and expenses");
    }
  }



  // ✅ Fetch all user accounts
  Future<List<Account>> getAccounts() async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse(ApiEndpoints.accounts),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['accounts'];
      return data.map((e) => Account.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load accounts");
    }
  }

// ✅ Fetch all categories
  Future<List<Category>> getCategories() async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse(ApiEndpoints.categories),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['categories'];
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  /// ✅ Fetch statistics grouped by category for income/expense
  Future<Map<String, dynamic>> getStatistics(int year, int month) async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse("${ApiEndpoints.transactions}/statistics?year=$year&month=$month"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("📊 Statistics API Response: $data");
      return data;
    } else {
      print("❌ Error fetching statistics: ${response.body}");
      throw Exception("Failed to fetch statistics");
    }
  }




  // ✅ Update an existing transaction
  Future<bool> updateTransaction(String transactionId, Map<String, dynamic> updatedData) async {
    final token = await _getToken();
    if (token == null) return false; // ❌ Return false if user is not authenticated

    // ✅ Fetch existing transaction details
    final transactionResponse = await http.get(
      Uri.parse("${ApiEndpoints.transactions}/$transactionId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (transactionResponse.statusCode != 200) return false;

    final transactionData = jsonDecode(transactionResponse.body)['transaction'];
    double oldAmount = double.tryParse(transactionData['amount'].toString()) ?? 0.0;
    String oldType = transactionData['type'];
    String accountId = transactionData['account_id'];

    // ✅ Fetch account balance
    final accountResponse = await http.get(
      Uri.parse("${ApiEndpoints.accounts}/$accountId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (accountResponse.statusCode != 200) return false;

    final accountData = jsonDecode(accountResponse.body)['account'];
    double currentBalance = double.tryParse(accountData['balance'].toString()) ?? 0.0;

    // ✅ Determine amount difference
    double newAmount = updatedData['amount'] != null ? double.parse(updatedData['amount'].toString()) : oldAmount;
    double balanceDifference = newAmount - oldAmount;

    // ✅ Adjust balance accordingly
    double updatedBalance;
    if (oldType == "Income") {
      updatedBalance = currentBalance - oldAmount + newAmount;
    } else {
      updatedBalance = currentBalance + oldAmount - newAmount;
    }

    // ✅ Prevent negative balance for expenses
    if (oldType == "Expense" && updatedBalance < 0) {
      print("❌ Insufficient funds! Update aborted.");
      return false;
    }

    // ✅ Proceed with transaction update
    final response = await http.put(
      Uri.parse("${ApiEndpoints.transactions}/$transactionId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      await updateAccountBalance(accountId, updatedBalance);
      await BudgetService().getBudgets();
      await BudgetService().getBudgetSummary();
      return true;
    } else {
      print("❌ Failed to update transaction: ${response.body}");
      return false;
    }
  }



  // ✅ Delete a transaction
  Future<bool> deleteTransaction(String transactionId) async {
    final token = await _getToken();
    if (token == null) return false; // ❌ Return false if user is not authenticated

    // ✅ Fetch transaction details before deletion
    final transactionResponse = await http.get(
      Uri.parse("${ApiEndpoints.transactions}/$transactionId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (transactionResponse.statusCode != 200) return false;

    final transactionData = jsonDecode(transactionResponse.body)['transaction'];
    double amount = double.tryParse(transactionData['amount'].toString()) ?? 0.0;
    String type = transactionData['type'];
    String accountId = transactionData['account_id'];

    // ✅ Fetch account balance
    final accountResponse = await http.get(
      Uri.parse("${ApiEndpoints.accounts}/$accountId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (accountResponse.statusCode != 200) return false;

    final accountData = jsonDecode(accountResponse.body)['account'];
    double currentBalance = double.tryParse(accountData['balance'].toString()) ?? 0.0;

    // ✅ Adjust balance to revert the transaction effect
    double updatedBalance = (type == "Income") ? currentBalance - amount : currentBalance + amount;

    // ✅ Proceed with transaction deletion
    final response = await http.delete(
      Uri.parse("${ApiEndpoints.transactions}/$transactionId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      await updateAccountBalance(accountId, updatedBalance);
      await BudgetService().getBudgets();
      await BudgetService().getBudgetSummary();
      return true;
    } else {
      print("❌ Failed to delete transaction: ${response.body}");
      return false;
    }
  }


  // ✅ Get monthly transactions grouped by day
  Future<Map<String, List<Transaction>>> getMonthlyTransactions(String year, String month) async {
    final _storage = FlutterSecureStorage();
    final token = await _storage.read(key: "auth_token");
    if (token == null) throw Exception("User not authenticated");

    try {
      final response = await http.get(
        Uri.parse("${ApiEndpoints.transactions}/month/$year/$month"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body)['transactions'];

        if (data.isEmpty) {
          return {}; // Return an empty map if no transactions exist
        }

        // ✅ Convert JSON response into Map<String, List<Transaction>>
        Map<String, List<Transaction>> transactionsByDay = {};
        data.forEach((day, transactionsList) {
          transactionsByDay[day] = (transactionsList as List)
              .map((json) => Transaction.fromJson(json)) // ✅ Ensure correct parsing
              .toList();
        });

        return transactionsByDay;
      } else {
        print("❌ API Error: ${response.body}");
        throw Exception("Failed to load monthly transactions");
      }
    } catch (e) {
      print("❌ Error: $e");
      throw Exception("An error occurred while fetching monthly transactions");
    }
  }


  // ✅ Get daily transactions
  Future<List<Transaction>> getDailyTransactions(String year, String month, String day) async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse("${ApiEndpoints.transactions}/day/$year/$month/$day"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body)['transactions'];
      return data.map((e) => Transaction.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load daily transactions");
    }
  }


  Future<Map<String, Map<String, double>>> getCalendarTransactions(String year, String month) async {
    final token = await _storage.read(key: "auth_token");
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse(ApiEndpoints.calendarTransactions(int.parse(year), int.parse(month))),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> transactionsList = jsonDecode(response.body)['transactions']; // ✅ Extract List

      Map<String, Map<String, double>> formattedTransactions = {};

      for (var item in transactionsList) {
        String date = item['date'];
        formattedTransactions[date] = {
          'total_income': double.parse(item['total_income'].toString()),
          'total_expenses': double.parse(item['total_expenses'].toString()),
        };
      }

      print("Processed Transactions: $formattedTransactions"); // ✅ Debugging
      return formattedTransactions;
    } else {
      throw Exception("Failed to load calendar transactions");
    }
  }



  // ✅ Get total income and expenses
  Future<Map<String, double>> getIncomeAndExpenses() async {
    final token = await _getToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse(ApiEndpoints.transactionSummary),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "total_income": double.tryParse(data['total_income'].toString()) ?? 0.0,
        "total_expenses": double.tryParse(data['total_expenses'].toString()) ?? 0.0,
      };
    } else {
      throw Exception("Failed to load income and expenses");
    }
  }
}
