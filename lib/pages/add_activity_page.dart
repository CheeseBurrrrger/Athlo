import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddActivityPage extends StatefulWidget {
  const AddActivityPage({Key? key}) : super(key: key);

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedType;
  final distanceController = TextEditingController();
  final timeController = TextEditingController();
  final caloriesController = TextEditingController();
  final notesController = TextEditingController();

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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {

                    final user = FirebaseAuth.instance.currentUser;
                    final username = user?.displayName ?? "Unknown User";

                    await FirebaseFirestore.instance.collection('activities').add({
                      "userName": username,
                      "activityType": selectedType,
                      "distance": distanceController.text,
                      "time": timeController.text,
                      "calories": caloriesController.text,
                      "notes": notesController.text,
                      "createdAt": FieldValue.serverTimestamp(),
                    });

                    Navigator.pop(context);
                  }
                },


                child: const Text(
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