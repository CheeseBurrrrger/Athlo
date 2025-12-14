import 'package:athlo/widgets/macro_badge.dart';
import 'package:flutter/material.dart';
import '../models/nutrition_food.dart';

class FoodTile extends StatelessWidget {
  final NutritionFood food;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const FoodTile({
    Key? key,
    required this.food,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.restaurant, color: _getCategoryColor(), size: 28),
        ),
        title: Text(
          food.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              MacroBadge(
                label: '${food.calories} kcal',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
              SizedBox(width: 8),
              MacroBadge(
                label: '${food.protein}g P',
                icon: Icons.egg,
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              MacroBadge(
                label: '${food.carbs}g C',
                icon: Icons.rice_bowl,
                color: Colors.green,
              ),
            ],
          ),
        ),
        trailing: showActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: onDelete,
                    ),
                ],
              )
            : Checkbox(
                value: isSelected,
                onChanged: onTap != null ? (_) => onTap!() : null,
                activeColor: _getCategoryColor(),
              ),
        onTap: onTap,
      ),
    );
  }

  Color _getCategoryColor() {
    switch (food.category.toLowerCase()) {
      case 'bulking':
        return Color(0xFF636CCB);
      case 'cutting':
        return Color(0xFF6E8CFB);
      case 'lean':
        return Color(0xFF50589C);
      default:
        return Color(0xFF3C467B);
    }
  }
}
