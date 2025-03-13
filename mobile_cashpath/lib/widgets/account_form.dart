import 'package:flutter/material.dart';
import 'package:mobile_cashpath/models/account_model.dart';
import 'package:mobile_cashpath/core/services/account_service.dart';
import 'package:mobile_cashpath/core/services/auth_service.dart';

class AccountForm extends StatefulWidget {
  final Account? account;
  final Function onSave;

  AccountForm({this.account, required this.onSave});

  @override
  _AccountFormState createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  String _accountType = "Savings";
  String _currency = "USD";
  String _icon = "default_icon";
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? "");
    _balanceController = TextEditingController(text: widget.account?.balance.toString() ?? "0.0");
    _accountType = widget.account?.accountType ?? "Savings";
    _currency = widget.account?.currency ?? "USD";
    _icon = widget.account?.icon ?? "default_icon";
    _isDefault = widget.account?.isDefault ?? false;
  }

  Future<void> _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        final token = await AuthService.getToken();
        final userId = await AuthService.getUserId();
        if (token == null || userId == null) return;

        final account = Account(
          id: widget.account?.id ?? "",
          userId: userId,
          name: _nameController.text,
          balance: double.tryParse(_balanceController.text) ?? 0.0,
          accountType: _accountType,
          currency: _currency,
          icon: _icon,
          isDefault: _isDefault,
        );

        if (widget.account == null) {
          await AccountService().createAccount(token, account);
        } else {
          await AccountService().updateAccount(token, widget.account!.id, account);
        }

        widget.onSave();
        Navigator.pop(context);
      } catch (e) {
        print("Error saving account: $e");
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (widget.account == null) return;

    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      await AccountService().deleteAccount(token, widget.account!.id);
      widget.onSave();
      Navigator.pop(context);
    } catch (e) {
      print("Error deleting account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.account == null ? "Add Account" : "Edit Account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 16),

              // ✅ Account Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Account Name"),
                validator: (value) => value!.isEmpty ? "Enter account name" : null,
              ),
              SizedBox(height: 10),

              // ✅ Balance Field
              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(labelText: "Balance"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter balance" : null,
              ),
              SizedBox(height: 10),

              // ✅ Account Type Dropdown
              DropdownButtonFormField<String>(
                value: _accountType,
                items: ["Savings", "Checking", "Credit", "Investment", "Loan"].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => _accountType = val!),
                decoration: InputDecoration(labelText: "Account Type"),
              ),
              SizedBox(height: 10),

              // ✅ Currency Dropdown
              DropdownButtonFormField<String>(
                value: _currency,
                items: ["USD", "EUR", "GBP", "JPY"].map((currency) {
                  return DropdownMenuItem(value: currency, child: Text(currency));
                }).toList(),
                onChanged: (val) => setState(() => _currency = val!),
                decoration: InputDecoration(labelText: "Currency"),
              ),
              SizedBox(height: 10),

              // ✅ Icon Field
              TextFormField(
                initialValue: _icon,
                decoration: InputDecoration(labelText: "Icon (optional)"),
                onChanged: (val) => setState(() => _icon = val),
              ),
              SizedBox(height: 10),

              // ✅ Default Account Toggle
              SwitchListTile(
                title: Text("Set as Default"),
                value: _isDefault,
                activeColor: Colors.green,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              SizedBox(height: 20),

              // ✅ Buttons Row
              Row(
                mainAxisAlignment: widget.account != null
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  if (widget.account != null)
                  // 🛑 Delete Button
                    ElevatedButton(
                      onPressed: _deleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text("Delete", style: TextStyle(color: Colors.white)),
                    ),

                  // ✅ Save Button
                  ElevatedButton(
                    onPressed: _saveAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
