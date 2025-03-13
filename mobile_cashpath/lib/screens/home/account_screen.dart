import 'package:flutter/material.dart';
import 'package:mobile_cashpath/models/account_model.dart';
import 'package:mobile_cashpath/core/services/account_service.dart';
import 'package:mobile_cashpath/core/services/auth_service.dart';
import 'package:mobile_cashpath/widgets/account_form.dart';

class AccountsScreen extends StatefulWidget {
  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Account> _accounts = [];
  double _totalBalance = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final accounts = await AccountService().getAccounts(token);
      final balance = await AccountService().getTotalBalance(token);

      setState(() {
        _accounts = accounts;
        _totalBalance = balance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching accounts: $e");
    }
  }

  void _showAccountForm({Account? account}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AccountForm(
          account: account,
          onSave: _fetchAccounts, // Refresh list after saving
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Accounts", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.green),
            onPressed: _fetchAccounts,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
        children: [
          _buildBalanceCard(),
          Expanded(child: _buildAccountList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccountForm(),
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        color: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Total Balance", style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 5),
              Text("\$${_totalBalance.toStringAsFixed(2)}",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountList() {
    return ListView.builder(
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final account = _accounts[index];

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: ListTile(
            leading: Icon(Icons.account_balance_wallet, color: Colors.green),
            title: Text(account.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: Text("${account.accountType} - ${account.currency}"),
            trailing: Text(
              "\$${account.balance.toStringAsFixed(2)}",
              style: TextStyle(
                color: account.balance < 0 ? Colors.red : Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showAccountForm(account: account),
          ),
        );
      },
    );
  }
}
