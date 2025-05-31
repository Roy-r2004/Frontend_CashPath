import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _showExpenses = true;
  bool _isLoading = true;
  double _total = 0.0;
  List<Map<String, dynamic>> _categories = [];
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    try {
      final data = await TransactionService().getStatistics(_selectedYear, _selectedMonth);

      setState(() {
        if (_showExpenses) {
          _total = (data['total_expenses'] as num?)?.toDouble() ?? 0.0;
          _categories = (data['expense_categories'] as List)
              .map<Map<String, dynamic>>((item) => {
            'name': item['name'],
            'amount': (item['amount'] as num?)?.toDouble() ?? 0.0,
            'percentage': (item['percentage'] as num?)?.toDouble() ?? 0.0,
          })
              .toList();
        } else {
          _total = (data['total_income'] as num?)?.toDouble() ?? 0.0;
          _categories = (data['income_categories'] as Map).values
              .map<Map<String, dynamic>>((item) => {
            'name': item['name'],
            'amount': (item['amount'] as num?)?.toDouble() ?? 0.0,
            'percentage': (item['percentage'] as num?)?.toDouble() ?? 0.0,
          })
              .toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching statistics: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Statistics", style: TextStyle(color: Colors.white)),
        actions: [_buildDateSelector()],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Column(
        children: [
          _buildToggleSwitch(),
          _buildTotalTitle(),
          _categories.isEmpty
              ? Expanded(child: Center(child: Text("No data available", style: TextStyle(color: Colors.white70))))
              : _buildPieChartWithList(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        DropdownButton<int>(
          value: _selectedMonth,
          dropdownColor: Colors.black,
          style: TextStyle(color: Colors.white),
          items: List.generate(12, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
            );
          }),
          onChanged: (value) {
            setState(() {
              _selectedMonth = value!;
              _isLoading = true;
            });
            _fetchStatistics();
          },
        ),
        DropdownButton<int>(
          value: _selectedYear,
          dropdownColor: Colors.black,
          style: TextStyle(color: Colors.white),
          items: List.generate(10, (index) {
            int year = DateTime.now().year - index;
            return DropdownMenuItem(value: year, child: Text("$year"));
          }),
          onChanged: (value) {
            setState(() {
              _selectedYear = value!;
              _isLoading = true;
            });
            _fetchStatistics();
          },
        ),
        SizedBox(width: 12),
      ],
    );
  }

  Widget _buildToggleSwitch() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Income", style: TextStyle(color: Colors.white)),
          Switch(
            value: _showExpenses,
            onChanged: (value) {
              setState(() {
                _showExpenses = value;
                _isLoading = true;
              });
              _fetchStatistics();
            },
            activeColor: Colors.redAccent,
          ),
          Text("Expenses", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTotalTitle() {
    return Column(
      children: [
        Text(
          "${DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth))}",
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        SizedBox(height: 6),
        Text(
          "${_showExpenses ? "Expenses" : "Income"} \$${_total.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Divider(thickness: 1, color: Colors.grey[700], height: 30),
      ],
    );
  }

  Widget _buildPieChartWithList() {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: List.generate(_categories.length, (index) {
                  final color = _generateRandomColor(index);
                  final item = _categories[index];
                  final isTouched = _touchedIndex == index;
                  return PieChartSectionData(
                    color: color,
                    value: item['percentage'],
                    title: isTouched ? item['name'] : "${item['percentage'].toStringAsFixed(1)}%",
                    titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isTouched ? 14 : 12),
                    radius: isTouched ? 70 : 60,
                  );
                }),
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex = response?.touchedSection?.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
          ),
          Divider(thickness: 1, color: Colors.grey[700]),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final item = _categories[index];
                final color = _generateRandomColor(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${item['percentage'].toStringAsFixed(0)}%",
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(item['name'], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Text(
                        "\$${item['amount'].toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Color _generateRandomColor(int index) {
    final Random random = Random(index);
    return Color.fromRGBO(
      100 + random.nextInt(155),
      100 + random.nextInt(155),
      100 + random.nextInt(155),
      1,
    );
  }
}
