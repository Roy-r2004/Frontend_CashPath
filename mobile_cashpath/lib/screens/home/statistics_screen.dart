import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_cashpath/core/services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final response = await ApiService.get('/transactions/summary');
    if (response != null) {
      setState(() {
        totalIncome = response['total_income'];
        totalExpenses = response['total_expenses'];
      });
    }

    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await ApiService.get('/categories');
    if (response != null) {
      setState(() {
        categories = response['categories'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Statistics"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Income: \$${totalIncome.toStringAsFixed(2)}  |  Expenses: \$${totalExpenses.toStringAsFixed(2)}",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: _buildChartSections(),
                borderData: FlBorderData(show: false),
                centerSpaceRadius: 40,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Text(category['icon'] ?? '💰', style: TextStyle(fontSize: 20)),
                  ),
                  title: Text(category['name'], style: TextStyle(color: Colors.white)),
                  trailing: Text("\$${category['total'] ?? 0.0}", style: TextStyle(color: Colors.white70)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections() {
    return categories.map((category) {
      final double value = category['total'] ?? 0.0;
      return PieChartSectionData(
        value: value,
        title: "\$${value.toStringAsFixed(1)}",
        color: _getRandomColor(),
        radius: 50,
      );
    }).toList();
  }

  Color _getRandomColor() {
    return Colors.primaries[categories.length % Colors.primaries.length];
  }
}
