import 'dart:convert';
import 'package:mobile_cashpath/models/category_model.dart';
import 'package:mobile_cashpath/models/account_model.dart';

class Transaction {
  final String id;
  final String userId;
  final String accountId;
  final String? categoryId;
  final double amount;
  final String type; // "Income" or "Expense"
  final String date;
  final String time;
  final String? note;
  final String? receiptImage;
  final bool isRecurring;
  final Account? account;
  final Category? category;

  Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    required this.time,
    this.note,
    this.receiptImage,
    required this.isRecurring,
    this.account,
    this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      accountId: json['account_id'].toString(),
      categoryId: json['category_id']?.toString(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'],
      date: json['date'],
      time: json['time'],
      note: json['note'],
      receiptImage: json['receipt_image'],
      isRecurring: json['is_recurring'] == true || json['is_recurring'] == 1,
      account: json['account'] != null ? Account.fromJson(json['account']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "account_id": accountId,
      "category_id": categoryId,
      "amount": amount,
      "type": type,
      "date": date,
      "time": time,
      "note": note,
      "receipt_image": receiptImage,
      "is_recurring": isRecurring ? 1 : 0,
    };
  }
}
