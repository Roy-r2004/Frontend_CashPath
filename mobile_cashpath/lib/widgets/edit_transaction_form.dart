import 'package:flutter/material.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';
import 'package:mobile_cashpath/core/services/auth_service.dart'; // ✅ Import AuthService
import 'package:mobile_cashpath/models/transaction_model.dart';

class EditTransactionForm extends StatefulWidget {
  final Transaction transaction;

  EditTransactionForm({required this.transaction});

  @override
  _EditTransactionFormState createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<EditTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeTransactionData();
    _fetchUserId();
  }

  /// ✅ Initialize transaction data
  void _initializeTransactionData() {
    _amountController.text = widget.transaction.amount.toString();
    _noteController.text = widget.transaction.note ?? "";
  }

  /// ✅ Fetch authenticated user ID
  Future<void> _fetchUserId() async {
    final userId = await AuthService.getUserId();
    setState(() => _userId = userId);
  }

  /// ✅ Submit the updated transaction (only `amount` and `note`)
  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;

    setState(() => _isSubmitting = true);

    bool success = await TransactionService().updateTransaction(
      widget.transaction.id,
      {
        "amount": double.parse(_amountController.text),
        "note": _noteController.text,
      },
    );

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context, true); // ✅ Refresh transaction details
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update transaction"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Transaction", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// ✅ Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Amount"),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter amount";
                  if (double.tryParse(value) == null) return "Enter a valid number";
                  return null;
                },
              ),

              /// ✅ Note Input
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "Note (Optional)"),
              ),

              SizedBox(height: 20),

              /// ✅ Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _updateTransaction,
                child: _isSubmitting ? CircularProgressIndicator() : Text("Update Transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
