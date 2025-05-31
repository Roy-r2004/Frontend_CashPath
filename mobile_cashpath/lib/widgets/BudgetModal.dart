import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cashpath/core/services/budget_service.dart';
import 'package:mobile_cashpath/core/services/transaction_service.dart';
import 'package:mobile_cashpath/models/category_model.dart';

class CreateBudgetModal extends StatefulWidget {
  final Function onSuccess;
  const CreateBudgetModal({super.key, required this.onSuccess});

  @override
  State<CreateBudgetModal> createState() => _CreateBudgetModalState();
}

class _CreateBudgetModalState extends State<CreateBudgetModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  String _period = 'Monthly';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isAutoAllocate = false;

  List<Category> _categories = [];
  String? _selectedCategory;
  Map<String, double> _percentages = {};

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final cats = await TransactionService().getCategories();
    setState(() {
      _categories = cats.where((cat) => cat.type == 'Expense').toList();
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first.id;
        _percentages = {
          for (var cat in _categories) cat.id: _defaultPercentageFor(cat.name),
        };
      }
    });
  }

  double _defaultPercentageFor(String name) {
    switch (name.toLowerCase()) {
      case 'rent':
        return 30;
      case 'groceries':
        return 20;
      case 'transportation':
        return 10;
      case 'utilities':
        return 8;
      case 'health':
        return 7;
      case 'entertainment':
        return 5;
      default:
        return 3;
    }
  }

  Future<void> _submitManual() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      bool created = await BudgetService().createBudget(
        categoryId: _selectedCategory!,
        amount: double.parse(_amountController.text),
        period: _period,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : null,
      );
      if (created) {
        widget.onSuccess();
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submitAutoAllocate() async {
    bool allocated = await BudgetService().autoAllocateBudget(_percentages);
    if (allocated) {
      widget.onSuccess();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text("Create Budget", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: Text("Manual"),
                  selected: !_isAutoAllocate,
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: !_isAutoAllocate ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (val) => setState(() => _isAutoAllocate = !val),
                ),
                ChoiceChip(
                  label: Text("Auto Allocate"),
                  selected: _isAutoAllocate,
                  selectedColor: Colors.deepPurple,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: _isAutoAllocate ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (val) => setState(() => _isAutoAllocate = val),
                ),

              ],
            ),
            const SizedBox(height: 16),
            _isAutoAllocate ? _buildAutoAllocateForm() : _buildManualForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildManualForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: _categories.map((cat) {
              return DropdownMenuItem(value: cat.id, child: Text(cat.name, style: TextStyle(color: Colors.black)));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            decoration: InputDecoration(labelText: "Select Category"),
            validator: (value) => value == null ? "Select a category" : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(labelText: "Amount"),
            validator: (value) {
              if (value == null || value.isEmpty) return "Enter amount";
              if (double.tryParse(value) == null) return "Enter valid number";
              return null;
            },
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _period,
            items: ['Monthly', 'Weekly', 'Custom']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => _period = value!),
            decoration: InputDecoration(labelText: "Period"),
          ),
          SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text("Start Date: ${DateFormat.yMMMd().format(_startDate)}", style: TextStyle(color: Colors.black)),
            trailing: Icon(Icons.calendar_today, size: 20, color: Colors.black54),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _startDate = picked);
            },
          ),
          if (_period == 'Custom')
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("End Date: ${_endDate != null ? DateFormat.yMMMd().format(_endDate!) : 'Select'}", style: TextStyle(color: Colors.black)),
              trailing: Icon(Icons.calendar_today, size: 20, color: Colors.black54),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _endDate = picked);
              },
            ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitManual,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: Size(double.infinity, 45),
            ),
            child: Text("Create Budget"),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoAllocateForm() {
    return Column(
      children: [
        ..._categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(cat.name,
                      style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
                ),
                SizedBox(width: 10),
                Container(
                  width: 65,
                  child: TextFormField(
                    initialValue: _percentages[cat.id]?.toStringAsFixed(0) ?? '',
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      suffixText: "%",
                      suffixStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _percentages[cat.id] = double.tryParse(val) ?? 0.0;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submitAutoAllocate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            minimumSize: Size(double.infinity, 45),
          ),
          child: Text("Auto Allocate"),
        )
      ],
    );
  }
}