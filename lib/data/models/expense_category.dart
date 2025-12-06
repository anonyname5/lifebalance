import 'package:flutter/material.dart';

/// Expense category model for custom categories
class ExpenseCategory {
  final int? id;
  final String name;
  final String iconName; // IconData code point as string
  final String colorHex; // Hex color code
  final int isDefault; // 1 for default, 0 for custom
  final int isActive; // 1 for active, 0 for inactive

  ExpenseCategory({
    this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    this.isDefault = 0,
    this.isActive = 1,
  });

  // Helper to get IconData from iconName
  IconData get iconData {
    final codePoint = int.tryParse(iconName) ?? Icons.category.codePoint;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  // Helper to get Color from hex
  Color get color {
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'color_hex': colorHex,
      'is_default': isDefault,
      'is_active': isActive,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconName: map['icon_name'] as String,
      colorHex: map['color_hex'] as String,
      isDefault: map['is_default'] as int? ?? 0,
      isActive: map['is_active'] as int? ?? 1,
    );
  }

  ExpenseCategory copyWith({
    int? id,
    String? name,
    String? iconName,
    String? colorHex,
    int? isDefault,
    int? isActive,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
    );
  }
}
