import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budget_tracker_app/providers/budget_provider.dart';
import 'package:budget_tracker_app/models/transaction.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  void _showEditDialog(BuildContext context, Transaction transaction, BudgetProvider budgetProvider) {
    final TextEditingController descriptionController = TextEditingController(text: transaction.description);
    final amountController = TextEditingController(text: transaction.amount.toString());
    String transactionType = transaction.type;
    DateTime selectedDate = transaction.date;
    String selectedCategory = transaction.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Transaction Type Toggle
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Expense'),
                            selected: transactionType == 'Expense',
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() => transactionType = 'Expense');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Income'),
                            selected: transactionType == 'Income',
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() => transactionType = 'Income');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Amount Field
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description Field
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: budgetProvider.categories
                          .map((cat) => DropdownMenuItem(
                                value: cat.name,
                                child: Text(cat.name),
                              ))
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => selectedCategory = value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Picker
                    ListTile(
                      title: Text(
                        'Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final updatedTransaction = Transaction(
                      id: transaction.id,
                      category: selectedCategory,
                      description: descriptionController.text,
                      amount: double.tryParse(amountController.text) ?? transaction.amount,
                      date: selectedDate,
                      type: transactionType,
                    );
                    budgetProvider.updateTransaction(updatedTransaction);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final transactions = budgetProvider.transactions;

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Dismissible(
          key: Key(transaction.id.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Are you sure you want to delete this transaction?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            budgetProvider.deleteTransaction(transaction.id!);
          },
          child: Card(
            elevation: 2,
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              leading: Icon(
                transaction.type == 'Expense' ? Icons.arrow_downward : Icons.arrow_upward,
                color: transaction.type == 'Expense' 
                  ? Theme.of(context).colorScheme.error 
                  : Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                transaction.description.isNotEmpty ? transaction.description : transaction.category,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              subtitle: Text(
                budgetProvider.getFormattedDate(transaction.date),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    NumberFormat.currency(locale: 'en_US').format(transaction.amount),
                    style: TextStyle(
                      color: transaction.type == 'Expense' 
                        ? Theme.of(context).colorScheme.error 
                        : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => _showEditDialog(context, transaction, budgetProvider),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}