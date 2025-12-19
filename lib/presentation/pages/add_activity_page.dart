import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../data/services/firebase_activity_service.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({super.key});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();

  final ActivityRepository _repository = FirebaseActivityService();

  String? _activityType;
  final _distanceController = TextEditingController();
  final _timeController = TextEditingController();
  final _caloriesController = TextEditingController();

  final List<String> _activityTypes = [
    'Running',
    'Cycling',
    'Gym Workout',
    'Yoga',
    'Swimming',
    'Hiking',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildField('Distance (km)', _distanceController),
              _buildField('Time (e.g. 28:45)', _timeController),
              _buildField('Calories Burned', _caloriesController),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _activityType,
      decoration: const InputDecoration(labelText: 'Activity Type'),
      items: _activityTypes
          .map((type) =>
          DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) => setState(() => _activityType = value),
      validator: (value) =>
      value == null ? 'Please select activity type' : null,
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
      value == null || value.isEmpty ? 'Required field' : null,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submit,
      child: const Text('Post Activity'),
    );
  }

  // ─────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final activity = Activity(
      userName: user.displayName ?? 'Anonymous',
      activityType: _activityType!,
      distance: _distanceController.text,
      time: _timeController.text,
      calories: _caloriesController.text,
      createdAt: DateTime.now(),
    );

    await _repository.addActivity(activity);

    if (mounted) Navigator.pop(context);
  }
}