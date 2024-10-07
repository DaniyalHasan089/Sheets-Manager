import 'package:flutter/material.dart';
import 'expense_form_page.dart'; // Import the form page with the ExpenseEntry class

class ConsolePage extends StatelessWidget {
  final List<ExpenseEntry> expenseEntries;

  const ConsolePage({super.key, required this.expenseEntries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Console'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: expenseEntries.length,
          itemBuilder: (context, index) {
            final entry = expenseEntries[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Expense: ${entry.expense}'),
                    Text('Cost: ${entry.cost}'),
                    Text('Quantity: ${entry.quantity}'),
                    Text('Vendor: ${entry.vendor ?? "N/A"}'),
                    Text('Expense Type: ${entry.expenseType}'),
                    Text('Date: ${entry.date}'),
                    Text('Reimbursed: ${entry.reimbursed ?? "N/A"}'),
                    Text(
                        'Receipt: ${entry.receiptFilePath != null ? "Uploaded" : "Not uploaded"}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
