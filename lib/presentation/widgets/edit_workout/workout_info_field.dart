import 'package:flutter/cupertino.dart';

class WorkoutInfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;

  const WorkoutInfoField({
    Key? key,
    required this.label,
    required this.controller,
    required this.placeholder,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(icon, color: CupertinoColors.systemGrey),
          ),
        ),
      ],
    );
  }
}
