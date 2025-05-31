import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';
import 'package:mobile_cashpath/core/services/category_service.dart';
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
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userId = await AuthService.getUserId();
    final accounts = await TransactionService().getAccounts();
    final categories = await TransactionService().getCategories();
    setState(() {
      _userId = userId;
      _accounts = accounts;
      _categories = categories;
      if (accounts.isNotEmpty) _selectedAccount = accounts.first.id;
      if (categories.isNotEmpty) _selectedCategory = categories.first.id;
    });
  }

  Future<void> _createCategoryDialog() async {
    final TextEditingController _categoryNameController = TextEditingController();
    String selectedType = _selectedType;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Create Category"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _categoryNameController,
                  decoration: InputDecoration(
                    labelText: "Category Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ChoiceChip(
                      label: Text("Income"),
                      selected: selectedType == "Income",
                      onSelected: (selected) {
                        if (selected) setStateDialog(() => selectedType = "Income");
                      },
                    ),
                    ChoiceChip(
                      label: Text("Expense"),
                      selected: selectedType == "Expense",
                      onSelected: (selected) {
                        if (selected) setStateDialog(() => selectedType = "Expense");
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Create"),
                onPressed: () async {
                  if (_categoryNameController.text.isNotEmpty) {
                    try {
                      final category = await CategoryService().createCategory(
                        name: _categoryNameController.text,
                        type: selectedType,
                      );
                      setState(() {
                        _categories.add(category);
                        _selectedCategory = category.id;
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Failed to create category"),
                        backgroundColor: Colors.red,
                      ));
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

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

  Future<void> _updateAccountBalance(String accountId, double amount, String type) async {
    Account selectedAccount = _accounts.firstWhere((acc) => acc.id == accountId);
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
      body: _userId == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter amount";
                  if (double.tryParse(value) == null) return "Enter a valid number";
                  return null;
                },
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
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
                  ),
                  Expanded(
                    child: ListTile(
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
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text("Income"),
                    selected: _selectedType == "Income",
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = "Income");
                    },
                  ),
                  SizedBox(width: 10),
                  ChoiceChip(
                    label: Text("Expense"),
                    selected: _selectedType == "Expense",
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = "Expense");
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedAccount,
                items: _accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedAccount = value),
                decoration: InputDecoration(
                  labelText: "Select Account",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null ? "Select an account" : null,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      decoration: InputDecoration(
                        labelText: "Select Category",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value == null ? "Select a category" : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blue),
                    onPressed: _createCategoryDialog,
                  ),
                ],
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: "Note (Optional)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SwitchListTile(
                title: Text("Recurring Transaction"),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTransaction,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Add Transaction"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
