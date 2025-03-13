import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cashpath/widgets/daily_transactions.dart';
import 'package:mobile_cashpath/widgets/monthly_transactions.dart';
import 'package:mobile_cashpath/widgets/calendar_transactions.dart';
import 'package:mobile_cashpath/widgets/transaction_detail.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';
import 'package:mobile_cashpath/widgets/add_transaction_form.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final TransactionService _transactionService = TransactionService();

  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchSummary();
  }

  /// Fetch income, expenses, and total balance
  void _fetchSummary() async {
    var summary = await _transactionService.getIncomeAndExpenses();
    setState(() {
      _totalIncome = summary['total_income'] ?? 0.0;
      _totalExpense = summary['total_expenses'] ?? 0.0;
      _totalBalance = _totalIncome - _totalExpense;
    });
  }

  /// Change the displayed month when clicking arrows
  void _changeMonth(int direction) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + direction, 1);
    });
    _fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMM().format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Transactions",
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchSummary, // ✅ Manually refresh totals
          ),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTransactionForm()),
              );
              if (result == true) {
                _fetchSummary(); // ✅ Refresh summary after adding transaction
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              formattedDate,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
        ),
      ),


      body: Column(
        children: [
          _buildSummaryRow(),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.redAccent,
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: "Daily"),
              Tab(text: "Calendar"),
              Tab(text: "Monthly"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DailyTransactions(
                  selectedDate: _selectedDate,
                  onTransactionTap: (transactionId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(transactionId: transactionId),
                      ),
                    );
                  },
                ),
                CalendarTransactions(selectedDate: _selectedDate),
                MonthlyTransactions(
                  selectedDate: _selectedDate,
                  onTransactionTap: (transactionId) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(transactionId: transactionId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Income, Expense, and Total Summary Row
  Widget _buildSummaryRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryItem("Income", _totalIncome, Colors.blue),
          _summaryItem("Exp.", _totalExpense, Colors.red),
          _summaryItem("Total", _totalBalance, Colors.black),
        ],
      ),
    );
  }

  /// Summary item widget
  Widget _summaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("\$${amount.toStringAsFixed(2)}", style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.black54, fontSize: 14)),
      ],
    );
  }
}
