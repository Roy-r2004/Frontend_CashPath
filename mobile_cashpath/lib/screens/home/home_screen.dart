import 'package:flutter/material.dart';
import 'package:mobile_cashpath/screens/home/transactions_screen.dart';
import 'package:mobile_cashpath/screens/home/statistics_screen.dart';
import 'package:mobile_cashpath/screens/home/account_screen.dart';
import 'package:mobile_cashpath/settings/settings_screen.dart';
import 'package:mobile_cashpath/screens/home/budget_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    TransactionsScreen(),
    StatisticsScreen(),
    AccountsScreen(),
    BudgetScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Transactions",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Accounts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: "Budget",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "More",
          ),
        ],
      ),
    );
  }
}
