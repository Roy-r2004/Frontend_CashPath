import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cashpath/models/transaction_model.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';
import 'package:mobile_cashpath/widgets/edit_transaction_form.dart'; // ✅ Import the edit form

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  TransactionDetailScreen({required this.transactionId});

  @override
  _TransactionDetailScreenState createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionService _transactionService = TransactionService();
  late Future<Transaction> _transaction;

  @override
  void initState() {
    super.initState();
    _transaction = _transactionService.getTransactionById(widget.transactionId);
  }

  void _deleteTransaction() async {
    bool success = await _transactionService.deleteTransaction(widget.transactionId);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to delete transaction", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  /// ✅ Opens Edit Transaction Form
  void _editTransaction(Transaction transaction) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionForm(transaction: transaction),
      ),
    );

    if (updated == true) {
      setState(() {
        _transaction = _transactionService.getTransactionById(widget.transactionId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Transaction Details", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white), // ✅ Edit Button
            onPressed: () async {
              final transaction = await _transaction;
              if (transaction != null) {
                _editTransaction(transaction);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Transaction>(
        future: _transaction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text("Transaction not found", style: TextStyle(color: Colors.white)));
          }

          Transaction transaction = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// **Income, Expense, Transfer Tabs**
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _transactionTypeButton("Income", transaction.type == "Income"),
                    _transactionTypeButton("Expense", transaction.type == "Expense"),
                    _transactionTypeButton("Transfer", transaction.type == "Transfer"),
                  ],
                ),

                SizedBox(height: 20),

                /// **Amount Section**
                Text(
                  "\$${transaction.amount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                /// **Date Section**
                SizedBox(height: 10),
                _detailRow("Date", DateFormat.yMMMd().format(DateTime.parse(transaction.date)), Icons.date_range),

                /// **Category Section**
                _detailRow("Category", transaction.category?.name ?? "Uncategorized", Icons.category),

                /// **Account Section**
                _detailRow("Account", "Cash", Icons.account_balance_wallet), // Placeholder for now

                /// **Note Section**
                _detailRow("Note", transaction.note ?? "No note", Icons.notes),

                SizedBox(height: 30),

                /// **Action Buttons (Delete, Copy, Bookmark)**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionButton(Icons.delete, "Delete", Colors.red, _deleteTransaction),
                    _actionButton(Icons.copy, "Copy", Colors.grey, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Transaction copied"), backgroundColor: Colors.green),
                      );
                    }),
                    _actionButton(Icons.bookmark_border, "Bookmark", Colors.amber, () {}),
                  ],
                ),

                /// **Description Section**
                Expanded(child: Container()), // Placeholder to balance the layout
              ],
            ),
          );
        },
      ),
    );
  }

  /// **Reusable Widget for Transaction Type Buttons**
  Widget _transactionTypeButton(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.red : Colors.grey[800],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {},
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  /// **Reusable Detail Row Widget**
  Widget _detailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          SizedBox(width: 10),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 16)),
          Spacer(),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// **Reusable Action Button Widget**
  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}
