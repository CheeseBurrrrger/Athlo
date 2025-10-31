import 'package:flutter/material.dart';

class LevelChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final Function(bool) onSelected;

  const LevelChip({
    Key? key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      side: BorderSide(color: color),
      onSelected: onSelected,
    );
  }
}