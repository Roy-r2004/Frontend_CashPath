import 'package:flutter/material.dart';
import 'package:mobile_cashpath/core/services/budget_service.dart';

class EditBudgetModal extends StatefulWidget {
  final String budgetId;
  final double initialAmount;
  final String initialStatus;
  final Function onSuccess;

  const EditBudgetModal({
    super.key,
    required this.budgetId,
    required this.initialAmount,
    required this.initialStatus,
    required this.onSuccess,
  });

  @override
  State<EditBudgetModal> createState() => _EditBudgetModalState();
}

class _EditBudgetModalState extends State<EditBudgetModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.initialAmount.toString());
    _status = widget.initialStatus;
  }

  Future<void> _updateBudget() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      final success = await BudgetService().updateBudget(
        widget.budgetId,
        amount: amount,
        status: _status,
      );

      if (success) {
        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to update budget")),
        );
      }
    }
  }

  Future<void> _deleteBudget() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Budget"),
        content: const Text("Are you sure you want to delete this budget?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final deleted = await BudgetService().deleteBudget(widget.budgetId);
      if (deleted) {
        widget.onSuccess();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to delete budget")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Text(
                "Edit Budget",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter amount";
                  if (double.tryParse(value) == null) return "Enter valid number";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Active', 'Expired']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
                decoration: InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _updateBudget,
                icon: const Icon(Icons.save),
                label: const Text("Update Budget"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _deleteBudget,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text("Delete Budget", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
