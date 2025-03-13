import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cashpath/models/transaction_model.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';
import 'package:mobile_cashpath/widgets/transaction_detail.dart';

class DailyTransactions extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String transactionId) onTransactionTap;

  DailyTransactions({required this.selectedDate, required this.onTransactionTap});

  @override
  _DailyTransactionsState createState() => _DailyTransactionsState();
}

class _DailyTransactionsState extends State<DailyTransactions> {
  final TransactionService _transactionService = TransactionService();
  late Future<List<Transaction>> _transactions;
  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = widget.selectedDate;
    _fetchTransactions();
  }

  void _fetchTransactions() {
    setState(() {
      _transactions = _transactionService.getDailyTransactions(
        currentDate.year.toString(),
        currentDate.month.toString(),
        currentDate.day.toString(),
      );
    });
  }

  void _changeDate(int days) {
    setState(() {
      currentDate = currentDate.add(Duration(days: days));
      _fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd().format(currentDate);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => _changeDate(-1),
              ),
              Text(formattedDate, style: TextStyle(color: Colors.black, fontSize: 16)),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onPressed: () => _changeDate(1),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Transaction>>(
            future: _transactions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No transactions found", style: TextStyle(color: Colors.black)));
              }

              List<Transaction> transactions = snapshot.data!;

              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  Transaction transaction = transactions[index];

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailScreen(transactionId: transaction.id),
                        ),
                      );
                    },
                    leading: Icon(
                      transaction.type == "Income" ? Icons.arrow_downward : Icons.arrow_upward,
                      color: transaction.type == "Income" ? Colors.blue : Colors.red,
                    ),
                    title: Text("\$${transaction.amount.toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text(transaction.category?.name ?? "Uncategorized",
                        style: TextStyle(color: Colors.black54, fontSize: 14)),
                    trailing: Text(transaction.time, style: TextStyle(color: Colors.black54, fontSize: 14)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}