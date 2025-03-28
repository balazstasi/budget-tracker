import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_tracker_app/providers/budget_provider.dart';
import 'package:budget_tracker_app/models/category.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  Category? _selectedCategory;
  String _selectedIcon = 'default'; // Default icon

  final List<Map<String, dynamic>> _availableIcons = [
    // Custom Icons
    {'name': 'home', 'icon': Icons.home},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'fast_food', 'icon': Icons.fastfood},
    {'name': 'car_rental', 'icon': Icons.car_rental},
    {'name': 'medical_services', 'icon': Icons.medical_services},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'flight', 'icon': Icons.flight},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'entertainment', 'icon': Icons.movie},
    {'name': 'money', 'icon': Icons.money},
    {'name': 'bus', 'icon': Icons.bus_alert_sharp},
    // Default Icon
    {'name': 'default', 'icon': Icons.category},
  ];

  Icon getIconFromName(String name) {
    final iconData = _availableIcons.firstWhere(
      (element) => element['name'] == name,
      orElse: () => {'name': 'category', 'icon': Icons.category},
    )['icon'];
    return Icon(iconData);
  }

  void _showIconSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Icon',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = _availableIcons[index];
              final isSelected = _selectedIcon == iconData['name'];
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedIcon = iconData['name'];
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primaryContainer 
                      : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        iconData['icon'],
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        iconData['name'].replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    List<Category> categories = budgetProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Dismissible(
                    key: Key(category.id.toString()),
                    direction: category.isDefault ? DismissDirection.none : DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (category.isDefault) return false;
                      
                      // Check if category has any transactions
                      final hasTransactions = await budgetProvider.categoryHasTransactions(category.name);
                      if (hasTransactions) {
                        // Show warning dialog
                        // ignore: use_build_context_synchronously
                        return showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Warning'),
                              content: const Text(
                                'This category has existing transactions. Deleting it will also delete all associated transactions. Are you sure you want to continue?'
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }

                      return showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text('Are you sure you want to delete this category?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      budgetProvider.deleteCategory(category.id!);
                    },
                    child: ListTile(
                      leading: getIconFromName(category.iconName),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          color: _selectedCategory?.id == category.id
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                          fontWeight: _selectedCategory?.id == category.id
                            ? FontWeight.bold
                            : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        category.isDefault 
                          ? 'Default category (cannot be deleted)'
                          : _selectedCategory?.id == category.id
                            ? 'Currently editing'
                            : '',
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedCategory?.id == category.id
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        ),
                      ),
                      tileColor: _selectedCategory?.id == category.id
                        ? Theme.of(context).colorScheme.primaryContainer.withAlpha(51)
                        : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedCategory?.id == category.id
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: _selectedCategory?.id == category.id
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = category;
                            _categoryNameController.text = category.name;
                            _selectedIcon = category.iconName;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Add/Edit Category'),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _categoryNameController,
                          decoration: const InputDecoration(
                            labelText: 'Category Name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a category name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 48, // Match TextField default height
                          child: TextButton(
                            onPressed: () => _showIconSelector(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  getIconFromName(_selectedIcon).icon,
                                  size: 24,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Icon',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedCategory == null) {
                            // Add new
                            final newCategory = Category(
                              name: _categoryNameController.text,
                              iconName: _selectedIcon,
                            );
                            budgetProvider.addCategory(newCategory);
                          } else {
                            // Update existing
                            final updatedCategory = Category(
                              id: _selectedCategory!.id,
                              name: _categoryNameController.text,
                              isDefault: _selectedCategory!.isDefault,
                              iconName: _selectedIcon,
                            );
                            budgetProvider.updateCategory(updatedCategory);
                            setState(() {
                              _selectedCategory = null;
                            });
                          }
                          _categoryNameController.clear();
                          setState(() {
                            _selectedIcon = 'category';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _selectedCategory == null ? 'Add Category' : 'Update Category',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }
}