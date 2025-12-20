import 'package:flutter/cupertino.dart';

class WorkoutBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController durationController;

  const WorkoutBasicInfoSection({
    Key? key,
    required this.nameController,
    required this.durationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Workout Name',
          controller: nameController,
          placeholder: 'Enter workout name',
          icon: CupertinoIcons.sportscourt,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Duration (minutes)',
          controller: durationController,
          placeholder: 'Enter duration',
          icon: CupertinoIcons.time,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
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
          keyboardType: keyboardType,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(icon, color: CupertinoColors.systemGrey),
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}