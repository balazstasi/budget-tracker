import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_tracker_app/providers/budget_provider.dart';
import 'package:budget_tracker_app/models/transaction.dart';
import 'package:budget_tracker_app/models/category.dart';
import 'package:intl/intl.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewTransactionScreenState createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String _transactionType = 'Expense'; // Default to expense
  String _amountDisplay = '0';
  bool _isDecimalMode = false;
  final bool _isLongPressing = false;
  final Duration _longPressAnimationDuration = const Duration(milliseconds: 300);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 365)), // Allow dates up to 1 year in future
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
            ),
            child: child!,
          );
        },
    );
    if (picked != null) {  // Removed redundant check
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    List<Category> categories = budgetProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Transaction Type (Expense/Income)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _transactionType = 'Expense';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _transactionType == 'Expense' 
                              ? Colors.red.withAlpha(100) 
                              : Colors.red.shade100,
                            border: Border.all(
                              color: _transactionType == 'Expense' 
                                ? Colors.red 
                                : Colors.red.shade100,
                              width: 2,
                            ),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.money_off,
                                color: _transactionType == 'Expense' 
                                  ? Colors.red 
                                  : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Expense',
                                style: TextStyle(
                                  color: _transactionType == 'Expense' 
                                    ? Colors.red 
                                    : Colors.grey,
                                  fontWeight: _transactionType == 'Expense' 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _transactionType = 'Income';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _transactionType == 'Income' 
                              ? Colors.green.withAlpha(100) 
                              : Colors.green.shade100,
                            border: Border.all(
                              color: _transactionType == 'Income' 
                                ? Colors.green 
                                : Colors.green.shade100,
                              width: 2,
                            ),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: _transactionType == 'Income' 
                                  ? Colors.green 
                                  : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Income',
                                style: TextStyle(
                                  color: _transactionType == 'Income' 
                                    ? Colors.green 
                                    : Colors.grey,
                                  fontWeight: _transactionType == 'Income' 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Category Dropdown
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: _selectedCategory ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Select Category',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1,
                                ),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = category.name;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _selectedCategory == category.name
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getIconData(category.iconName),
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            category.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    isScrollControlled: true,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
                  );
                },
                validator: (value) => _selectedCategory == null ? 'Please select a category' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: 480, // Increased height to accommodate the Add button
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(double.parse(_amountDisplay))}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: Column(
                          children: [
                            // Main number pad (1-9, 0, ., delete)
                            Expanded(
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.5,
                                ),
                                itemCount: 12, // 9 numbers + 0, ., delete
                                itemBuilder: (context, index) {
                                  if (index < 9) {
                                    final number = [1, 2, 3, 4, 5, 6, 7, 8, 9][index];
                                    return AnimatedNumPadButton(
                                      child: Text(
                                        number.toString(),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (_amountDisplay == '0') {
                                            _amountDisplay = number.toString();
                                          } else {
                                            _amountDisplay += number.toString();
                                          }
                                        });
                                      },
                                    );
                                  } else if (index == 10) {
                                    return AnimatedNumPadButton(
                                      child: const Text('0', style: TextStyle(fontSize: 24)),
                                      onPressed: () {
                                        setState(() {
                                          if (_amountDisplay != '0') {
                                            _amountDisplay += '0';
                                          }
                                        });
                                      },
                                    );
                                  } else if (index == 9) {
                                    return AnimatedNumPadButton(
                                      child: const Text('.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        setState(() {
                                          if (!_amountDisplay.contains('.')) {
                                            _isDecimalMode = true;
                                            _amountDisplay += '.';
                                          }
                                        });
                                      },
                                    );
                                  } else {
                                    return AnimatedNumPadButton(
                                      child: const Icon(Icons.backspace_outlined),
                                      onPressed: () {
                                        setState(() {
                                          if (_amountDisplay.length > 1) {
                                            _amountDisplay = _amountDisplay.substring(0, _amountDisplay.length - 1);
                                            if (!_amountDisplay.contains('.')) {
                                              _isDecimalMode = false;
                                            }
                                          } else {
                                            _amountDisplay = '0';
                                            _isDecimalMode = false;
                                          }
                                        });
                                      },
                                      onLongPress: () {
                                        setState(() {
                                          _amountDisplay = '0';
                                          _isDecimalMode = false;
                                        });
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                            // Add Transaction button
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final transaction = Transaction(
                                      category: _selectedCategory!,
                                      description: _descriptionController.text,
                                      amount: double.parse(_amountDisplay),
                                      date: _selectedDate,
                                      type: _transactionType,
                                    );
                                    budgetProvider.addTransaction(transaction);
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text(
                                  'ADD TRANSACTION',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDate.day == DateTime.now().day ? Theme.of(context).primaryColor : Colors.grey.shade200,
                          foregroundColor: _selectedDate.day == DateTime.now().day ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime.now();
                          });
                        },
                        child: const Text('Today'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDate.day == DateTime.now().day - 1 ? Theme.of(context).primaryColor : Colors.grey.shade200,
                          foregroundColor: _selectedDate.day == DateTime.now().day - 1 ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime.now().subtract(const Duration(days: 1));
                          });
                        },
                        child: const Text('Yesterday'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_selectedDate.day != DateTime.now().day && _selectedDate.day != DateTime.now().day - 1) 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.shade200,
                          foregroundColor: (_selectedDate.day != DateTime.now().day && _selectedDate.day != DateTime.now().day - 1) 
                            ? Colors.white 
                            : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme,
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        child: Text(
                          (_selectedDate.day != DateTime.now().day && _selectedDate.day != DateTime.now().day - 1)
                            ? _getFormattedButtonDate(_selectedDate)
                            : 'Select Date',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    final Map<String, IconData> iconMap = {
      'home': Icons.home,
      'shopping_cart': Icons.shopping_cart,
      'fast_food': Icons.fastfood,
      'car_rental': Icons.car_rental,
      'medical_services': Icons.medical_services,
      'school': Icons.school,
      'flight': Icons.flight,
      'restaurant': Icons.restaurant,
      'default': Icons.category,
    };
    
    return iconMap[iconName] ?? Icons.category;
  }

  String _getFormattedButtonDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}

class AnimatedNumPadButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  const AnimatedNumPadButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
  });

  @override
  State<AnimatedNumPadButton> createState() => _AnimatedNumPadButtonState();
}

class _AnimatedNumPadButtonState extends State<AnimatedNumPadButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(4),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}