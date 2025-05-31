import 'package:flutter/material.dart';
import 'package:mobile_cashpath/core/services/budget_service.dart';
import 'package:mobile_cashpath/widgets/BudgetModal.dart';
import 'package:mobile_cashpath/widgets/EditBudgetModal.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _isLoading = true;
  List<dynamic> _budgets = [];
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    try {
      final budgets = await BudgetService().getBudgets();
      final summary = await BudgetService().getBudgetSummary();
      setState(() {
        _budgets = budgets;
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching budgets: $e");
      setState(() => _isLoading = false);
    }
  }

  void _openCreateModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CreateBudgetModal(onSuccess: _fetchBudgets),
      ),
    );
  }

  void _openEditModal(dynamic budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EditBudgetModal(
          budgetId: budget['id'],
          initialAmount: double.tryParse(budget['amount'].toString()) ?? 0,
          initialStatus: budget['status'],
          onSuccess: _fetchBudgets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Budgets", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openCreateModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : RefreshIndicator(
        onRefresh: _fetchBudgets,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            Text("My Budgets", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._budgets.map((budget) => _buildBudgetItem(budget)).toList(),
            if (_budgets.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(child: Text("No budgets created yet.")),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    double total = double.tryParse(_summary['total_budget']?.toString() ?? '0') ?? 0;
    double spent = double.tryParse(_summary['total_spent']?.toString() ?? '0') ?? 0;
    double remaining = double.tryParse(_summary['remaining']?.toString() ?? '0') ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Summary", style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 10),
            Text("\$${total.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text("Spent", style: TextStyle(color: Colors.white70)),
                    Text("\$${spent.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white)),
                  ],
                ),
                Column(
                  children: [
                    const Text("Remaining", style: TextStyle(color: Colors.white70)),
                    Text("\$${remaining.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItem(dynamic budget) {
    double amount = double.tryParse(budget['amount'].toString()) ?? 0;
    double spent = double.tryParse(budget['spent_amount'].toString()) ?? 0;
    double remaining = amount - spent;
    String status = budget['status'];

    double percentage = amount > 0 ? (spent / amount) * 100 : 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: status == 'Active' ? Colors.green : Colors.grey,
          child: const Icon(Icons.pie_chart, color: Colors.white),
        ),
        title: Text(budget['category']['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: percentage / 100,
              color: Colors.deepPurple,
              backgroundColor: Colors.deepPurple.shade100,
            ),
            const SizedBox(height: 4),
            Text("Allocated: \$${amount.toStringAsFixed(2)} | Spent: \$${spent.toStringAsFixed(2)} | Remaining: \$${remaining.toStringAsFixed(2)}"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.deepPurple),
          onPressed: () => _openEditModal(budget),
        ),
      ),
    );
  }
}