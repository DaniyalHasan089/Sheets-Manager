import 'package:flutter/material.dart';
import 'expense_form_page.dart';
import 'console_page.dart';

List<ExpenseEntry> expenseEntries = [];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Expense Form'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ExpenseFormPage(expenseEntries: expenseEntries)),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Console'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ConsolePage(expenseEntries: expenseEntries)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
