import 'package:flutter/cupertino.dart';

class WorkoutFormHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const WorkoutFormHeader({
    Key? key,
    required this.title,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: CupertinoColors.systemBackground,
      border: null,
      middle: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Text('Close'),
        onPressed: onClose,
      ),
    );
  }
}