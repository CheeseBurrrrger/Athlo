import 'package:flutter/cupertino.dart';

class EditWorkoutHeader extends StatelessWidget {
  final VoidCallback onClose;

  const EditWorkoutHeader({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Edit Workout',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.xmark),
                onPressed: onClose,
              ),
            ],
          ),
        ),
        Container(height: 0.5, color: CupertinoColors.systemGrey4),
      ],
    );
  }
}