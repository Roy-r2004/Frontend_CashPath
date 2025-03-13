import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';
import 'package:mobile_cashpath/models/account_model.dart';
import 'package:mobile_cashpath/models/category_model.dart';
import 'package:mobile_cashpath/core/services/auth_service.dart';

class AddTransactionForm extends StatefulWidget {
  @override
  _AddTransactionFormState createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = "Expense";
  String? _selectedAccount;
  String? _selectedCategory;
  bool _isRecurring = false;
  bool _isSubmitting = false;
  String? _userId;

  List<Account> _accounts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchAccountsAndCategories();
    _fetchUserId();
  }

  /// ✅ Fetch user ID
  Future<void> _fetchUserId() async {
    final userId = await AuthService.getUserId();
    setState(() => _userId = userId);
  }

  /// ✅ Fetch accounts and categories
  Future<void> _fetchAccountsAndCategories() async {
    final accounts = await TransactionService().getAccounts();
    final categories = await TransactionService().getCategories();

    setState(() {
      _accounts = accounts;
      _categories = categories;
      if (accounts.isNotEmpty) _selectedAccount = accounts.first.id;
      if (categories.isNotEmpty) _selectedCategory = categories.first.id;
    });
  }

  /// ✅ Submit the transaction and update account balance
  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;

    setState(() => _isSubmitting = true);

    double amount = double.parse(_amountController.text);

    bool success = await TransactionService().createTransaction(
      userId: _userId!,
      accountId: _selectedAccount!,
      categoryId: _selectedCategory!,
      amount: amount,
      type: _selectedType,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      time: "${_selectedTime.hour}:${_selectedTime.minute}:00",
      note: _noteController.text,
      isRecurring: _isRecurring,
    );

    // ✅ If transaction is successful, update the account balance
    if (success) {
      await _updateAccountBalance(_selectedAccount!, amount, _selectedType);
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to add transaction"),
        backgroundColor: Colors.red,
      ));
    }

    setState(() => _isSubmitting = false);
  }

  /// ✅ Update account balance after transaction
  Future<void> _updateAccountBalance(String accountId, double amount, String type) async {
    Account? selectedAccount = _accounts.firstWhere((acc) => acc.id == accountId, orElse: () => Account(
      id: accountId,
      userId: _userId!,
      name: "",
      balance: 0.0,
      accountType: "",
      currency: "",
      icon: "",
      isDefault: false,
    ));

    if (selectedAccount == null) return;

    double updatedBalance = (type == "Income")
        ? selectedAccount.balance + amount
        : selectedAccount.balance - amount;

    await TransactionService().updateAccountBalance(accountId, updatedBalance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Transaction", style: TextStyle(color: Colors.black)),
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

              /// ✅ Date Picker
              ListTile(
                title: Text("Date: ${DateFormat.yMMMd().format(_selectedDate)}"),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) setState(() => _selectedDate = pickedDate);
                },
              ),

              /// ✅ Time Picker
              ListTile(
                title: Text("Time: ${_selectedTime.format(context)}"),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) setState(() => _selectedTime = pickedTime);
                },
              ),

              /// ✅ Transaction Type Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ChoiceChip(
                    label: Text("Income"),
                    selected: _selectedType == "Income",
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = "Income");
                    },
                  ),
                  ChoiceChip(
                    label: Text("Expense"),
                    selected: _selectedType == "Expense",
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = "Expense");
                    },
                  ),
                ],
              ),

              /// ✅ Account Dropdown
              DropdownButtonFormField<String>(
                value: _selectedAccount,
                items: _accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedAccount = value),
                decoration: InputDecoration(labelText: "Select Account"),
                validator: (value) => value == null ? "Select an account" : null,
              ),

              /// ✅ Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                decoration: InputDecoration(labelText: "Select Category"),
                validator: (value) => value == null ? "Select a category" : null,
              ),

              /// ✅ Note Input
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: "Note (Optional)"),
              ),

              /// ✅ Recurring Transaction Switch
              SwitchListTile(
                title: Text("Recurring Transaction"),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),

              /// ✅ Submit Button
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTransaction,
                child: _isSubmitting ? CircularProgressIndicator() : Text("Add Transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
