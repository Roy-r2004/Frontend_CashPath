import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';

class CalendarTransactions extends StatefulWidget {
  final DateTime selectedDate;

  CalendarTransactions({required this.selectedDate});

  @override
  _CalendarTransactionsState createState() => _CalendarTransactionsState();
}

class _CalendarTransactionsState extends State<CalendarTransactions> {
  final TransactionService _transactionService = TransactionService();
  late Future<Map<String, Map<String, double>>> _transactions;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  /// Fetch transactions for the selected month
  void _fetchTransactions() {
    setState(() {
      _transactions = _transactionService.getCalendarTransactions(
        _focusedDay.year.toString(),
        _focusedDay.month.toString(),
      );
    });
  }

  /// Handle Day Selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  /// Change Month
  void _changeMonth(int direction) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + direction, 1);
    });
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<Map<String, Map<String, double>>>(
      future: _transactions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text("Error loading calendar transactions", style: TextStyle(color: Colors.black)));
        }

        Map<String, Map<String, double>> transactionsData = snapshot.data!;

        return Column(
          children: [
            /// **📅 Calendar Header with Month Switch**
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, color: Colors.black),
                    onPressed: () => _changeMonth(-1),
                  ),
                  Column(
                    children: [
                      Text(
                        DateFormat.yMMMM().format(_focusedDay),
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text("Swipe to change month", style: TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, color: Colors.black),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ),

            /// **📅 Scrollable Calendar Widget**
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: _onDaySelected,
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        availableCalendarFormats: {
                          CalendarFormat.month: 'Month',
                          CalendarFormat.week: 'Week',
                          CalendarFormat.twoWeeks: '2 Weeks'
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          selectedDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                          markersMaxCount: 3,
                          markerMargin: EdgeInsets.only(top: 2),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          formatButtonShowsNext: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                            if (transactionsData.containsKey(formattedDate)) {
                              double totalIncome = transactionsData[formattedDate]?['total_income'] ?? 0.0;
                              double totalExpenses = transactionsData[formattedDate]?['total_expenses'] ?? 0.0;
                              double totalBalance = totalIncome - totalExpenses;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("\$${totalIncome.toStringAsFixed(0)}",
                                      style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.03)),
                                  Text("\$${totalExpenses.toStringAsFixed(0)}",
                                      style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.03)),
                                  Text("\$${totalBalance.toStringAsFixed(0)}",
                                      style: TextStyle(color: Colors.black, fontSize: screenWidth * 0.03)),
                                ],
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    /// **📊 Selected Day Summary**
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _selectedDay != null
                          ? Column(
                        children: [
                          Text(
                            "Summary for ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}",
                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          _buildSummaryRow(transactionsData, _selectedDay!)
                        ],
                      )
                          : Text("Select a date to view summary", style: TextStyle(color: Colors.black54)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// **📌 Summary Widget**
  Widget _buildSummaryRow(Map<String, Map<String, double>> transactionsData, DateTime selectedDate) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    double income = transactionsData[formattedDate]?['total_income'] ?? 0.0;
    double expenses = transactionsData[formattedDate]?['total_expenses'] ?? 0.0;
    double total = income - expenses;

    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          _summaryItem("Income", income, Colors.blue),
          _summaryItem("Expenses", expenses, Colors.red),
          _summaryItem("Balance", total, total >= 0 ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  /// **📌 Summary Item Widget**
  Widget _summaryItem(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          Text("\$${amount.toStringAsFixed(2)}", style: TextStyle(color: color, fontSize: 16)),
        ],
      ),
    );
  }
}
