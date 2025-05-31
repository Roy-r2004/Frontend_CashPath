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
      print("❌ Error fetching accounts: $e");
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
          onSave: _fetchAccounts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "My Accounts",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
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
          SizedBox(height: 8),
          Expanded(child: _buildAccountList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountForm(),
        backgroundColor: Colors.green,
        label: Row(
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 6),
            Text("Add Account"),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Balance",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            "\$${_totalBalance.toStringAsFixed(2)}",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList() {
    return ListView.builder(
      itemCount: _accounts.length,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final account = _accounts[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 4)),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(Icons.account_balance_wallet, color: Colors.green),
            ),
            title: Text(account.name, style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text("${account.accountType} • ${account.currency}"),
            trailing: Text(
              "\$${account.balance.toStringAsFixed(2)}",
              style: TextStyle(
                color: account.balance < 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: () => _showAccountForm(account: account),
          ),
        );
      },
    );
  }
}
