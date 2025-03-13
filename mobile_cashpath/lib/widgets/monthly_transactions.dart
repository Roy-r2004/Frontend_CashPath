import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cashpath/models/transaction_model.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';
import 'package:mobile_cashpath/widgets/transaction_detail.dart';

class MonthlyTransactions extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String transactionId) onTransactionTap;

  MonthlyTransactions({required this.selectedDate, required this.onTransactionTap});

  @override
  _MonthlyTransactionsState createState() => _MonthlyTransactionsState();
}

class _MonthlyTransactionsState extends State<MonthlyTransactions> {
  final TransactionService _transactionService = TransactionService();
  late Future<Map<String, List<Transaction>>> _monthlyTransactions;
  late DateTime currentMonth;

  @override
  void initState() {
    super.initState();
    currentMonth = widget.selectedDate;
    _fetchTransactions();
  }

  void _fetchTransactions() {
    setState(() {
      _monthlyTransactions = _transactionService.getMonthlyTransactions(
        currentMonth.year.toString(),
        currentMonth.month.toString(),
      );
    });
  }

  void _changeMonth(int months) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + months, 1);
      _fetchTransactions();
    });
  }

  String getWeekRange(String day) {
    int dayNum = int.parse(day);
    DateTime startDate = DateTime(currentMonth.year, currentMonth.month, dayNum);
    DateTime endDate = startDate.add(Duration(days: 6));

    if (endDate.month != currentMonth.month) {
      endDate = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    }

    return "${DateFormat('MM/dd').format(startDate)} ~ ${DateFormat('MM/dd').format(endDate)}";
  }

  @override
  Widget build(BuildContext context) {
    String formattedMonth = DateFormat.yMMMM().format(currentMonth);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => _changeMonth(-1),
              ),
              Column(
                children: [
                  Text(formattedMonth, style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    "${DateFormat('MM/dd').format(DateTime(currentMonth.year, currentMonth.month, 1))} ~ ${DateFormat('MM/dd').format(DateTime(currentMonth.year, currentMonth.month + 1, 0))}",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<Map<String, List<Transaction>>>(
            future: _monthlyTransactions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(
                  child: Text("No transactions found", style: TextStyle(color: Colors.black)),
                );
              }

              var transactionsByWeek = snapshot.data!;

              return ListView.builder(
                itemCount: transactionsByWeek.length,
                itemBuilder: (context, index) {
                  String day = transactionsByWeek.keys.elementAt(index);
                  List<Transaction> transactions = transactionsByWeek[day] ?? [];

                  double totalIncome = transactions.where((t) => t.type == "Income").fold(0, (sum, t) => sum + t.amount);
                  double totalExpense = transactions.where((t) => t.type == "Expense").fold(0, (sum, t) => sum + t.amount);
                  double total = totalIncome - totalExpense;

                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(getWeekRange(day),
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("\$${totalIncome.toStringAsFixed(2)}",
                                    style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold)),
                                Text("\$${totalExpense.toStringAsFixed(2)}",
                                    style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                                Text("Total: \$${total.toStringAsFixed(2)}",
                                    style: TextStyle(color: Colors.black87, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: transactions.map((transaction) {
                          return ListTile(
                            onTap: () {
                              widget.onTransactionTap(transaction.id);
                            },
                            leading: Icon(transaction.type == "Income" ? Icons.arrow_downward : Icons.arrow_upward,
                                color: transaction.type == "Income" ? Colors.blue : Colors.red),
                            title: Text("\$${transaction.amount.toStringAsFixed(2)}",
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                            subtitle: Text(transaction.category?.name ?? "Uncategorized",
                                style: TextStyle(color: Colors.black54, fontSize: 14)),
                          );
                        }).toList(),
                      ),
                    ],
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
