import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:budget_tracker_app/providers/budget_provider.dart';

class MonthlySummary extends StatelessWidget {
  const MonthlySummary({super.key});

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];
    
    // Add empty slots for days before the first day of the month
    int firstWeekday = firstDay.weekday;
    for (int i = 1; i < firstWeekday; i++) {
      days.add(firstDay.subtract(Duration(days: firstWeekday - i)));
    }
    
    // Add all days of the month
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    
    // Add empty slots to complete the last week
    int remainingDays = 7 - (days.length % 7);
    if (remainingDays < 7) {
      for (int i = 1; i <= remainingDays; i++) {
        days.add(lastDay.add(Duration(days: i)));
      }
    }
    
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final totalIncome = budgetProvider.totalIncome;
    final totalExpenses = budgetProvider.totalExpenses;
    final balance = totalIncome - totalExpenses;
    final selectedMonth = budgetProvider.selectedMonth;
    final dailyBudget = totalIncome / DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final transactions = budgetProvider.transactions;

    // Calculate daily expenses
    Map<int, double> dailyExpenses = {};
    for (var transaction in transactions) {
      if (transaction.type == 'Expense') {
        final day = transaction.date.day;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + transaction.amount;
      }
    }

    return Column(
      children: [
        // Month selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                budgetProvider.setSelectedMonth(DateTime(selectedMonth.year, selectedMonth.month - 1, 1));
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(selectedMonth),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                budgetProvider.setSelectedMonth(DateTime(selectedMonth.year, selectedMonth.month + 1, 1));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Calendar header
        Row(
          children: const [
            Expanded(child: Text('Mon', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('Tue', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('Wed', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('Thu', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('Fri', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('Sat', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(child: Text('Sun', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 8),
        
        // Calendar grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          children: _getDaysInMonth(selectedMonth).map((date) {
            final isCurrentMonth = date.month == selectedMonth.month;
            final dayExpense = dailyExpenses[date.day] ?? 0;
            final expenseRatio = dayExpense / dailyBudget;
            final isOverBudget = expenseRatio > 1;
            
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  if (isCurrentMonth && dayExpense > 0)
                    Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: expenseRatio.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isOverBudget 
                              ? Theme.of(context).colorScheme.error.withOpacity(0.2)
                              : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isCurrentMonth 
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: isCurrentMonth && dayExpense > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isCurrentMonth && dayExpense > 0)
                          Text(
                            NumberFormat.compact().format(dayExpense),
                            style: TextStyle(
                              fontSize: 10,
                              color: isOverBudget 
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Budget:',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(locale: 'en_US', symbol: '\$').format(dailyBudget),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Balance:',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(locale: 'en_US', symbol: '\$').format(balance),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: balance >= 0 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}