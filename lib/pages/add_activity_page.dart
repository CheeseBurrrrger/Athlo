// pages/add_activity.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/activity_goal_integration.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({Key? key}) : super(key: key);

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final _activityIntegration = ActivityGoalIntegration();

  String? selectedType;
  final distanceController = TextEditingController();
  final timeController = TextEditingController();
  final caloriesController = TextEditingController();
  final notesController = TextEditingController();

  bool _isSubmitting = false;

  final List<String> activityTypes = [
    "Running",
    "Cycling",
    "Gym Workout",
    "Yoga",
    "Swimming",
    "Hiking",
    "Lari Bolo"
  ];

  @override
  void dispose() {
    distanceController.dispose();
    timeController.dispose();
    caloriesController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1974F5),
        title: const Text(
            "Add Activity",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Activity Type",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Dropdown
              DropdownButtonFormField<String>(
                value: selectedType,
                items: activityTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: _inputDecoration(),
                onChanged: (value) {
                  setState(() => selectedType = value);
                },
                validator: (value) =>
                value == null ? "Please select activity type" : null,
              ),

              const SizedBox(height: 20),

              _buildTextField("Distance (km)", distanceController),
              _buildTextField("Time (e.g. 28:45)", timeController),
              _buildTextField("Calories Burned", caloriesController),

              const SizedBox(height: 20),
              const Text("Notes (optional)"),
              const SizedBox(height: 8),
              TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: _inputDecoration(),
              ),

              const SizedBox(height: 30),

              // Submit button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E8CFB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitActivity,
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  "Post Activity",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final username = user.displayName ?? "Unknown User";
      final userID = user.uid;
      final now = DateTime.now();

      // Add activity to Firestore
      final docRef = await FirebaseFirestore.instance.collection('activities').add({
        "userName": username,
        "userID": userID, // Add userID for easier querying
        "activityType": selectedType,
        "distance": distanceController.text,
        "time": timeController.text,
        "calories": caloriesController.text,
        "notes": notesController.text,
        "createdAt": FieldValue.serverTimestamp(),
        "syncedToGoals": false, // Mark as not yet synced
      });

      // Immediately process this activity with goals
      await _activityIntegration.processNewActivity(
        userID: userID,
        activityId: docRef.id,
        activityType: selectedType!,
        calories: caloriesController.text,
        time: timeController.text,
        createdAt: now,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Activity posted and synced with goals!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Go back to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting activity: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(),
          validator: (value) =>
          (value == null || value.isEmpty) ? "Required field" : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
