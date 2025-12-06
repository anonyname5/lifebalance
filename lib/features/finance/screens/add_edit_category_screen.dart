import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/expense_category_provider.dart';
import '../../../data/models/expense_category.dart';

/// Screen for adding/editing expense categories
class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final ExpenseCategory? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = AppColors.primary;

  // Available icons
  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.movie,
    Icons.receipt,
    Icons.medical_services,
    Icons.school,
    Icons.category,
    Icons.home,
    Icons.work,
    Icons.fitness_center,
    Icons.flight,
    Icons.local_gas_station,
    Icons.phone,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.shopping_cart,
    Icons.local_movies,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.pets,
    Icons.child_care,
    Icons.celebration,
    Icons.local_cafe,
    Icons.fastfood,
    Icons.hotel,
    Icons.beach_access,
  ];

  // Available colors
  final List<Color> _availableColors = [
    const Color(0xFF6366F1), // Primary
    const Color(0xFF10B981), // Success
    const Color(0xFFF59E0B), // Warning
    const Color(0xFFEF4444), // Error
    const Color(0xFF3B82F6), // Info
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFF14B8A6), // Teal
    const Color(0xFFF97316), // Orange
    const Color(0xFF84CC16), // Lime
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF6366F1), // Indigo
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.iconData;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
        actions: [
          TextButton(
            onPressed: _saveCategory,
            child: const Text(
              AppStrings.save,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Icon Selection
              Text(
                'Select Icon',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableIcons.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        border: Border.all(
                          color: isSelected ? _selectedColor : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedColor : Colors.grey,
                        size: 28,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Color Selection
              Text(
                'Select Color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final category = ExpenseCategory(
        id: widget.category?.id,
        name: _nameController.text.trim(),
        iconName: _selectedIcon.codePoint.toString(),
        colorHex: '#${_selectedColor.value.toRadixString(16).substring(2)}',
        isDefault: 0,
        isActive: 1,
      );

      if (widget.category == null) {
        await ref.read(expenseCategoryNotifierProvider.notifier).addCategory(category);
      } else {
        await ref.read(expenseCategoryNotifierProvider.notifier).updateCategory(category);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.category == null
                ? 'Category added successfully'
                : 'Category updated successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
