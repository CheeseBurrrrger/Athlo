import 'package:athlo/models/exercise.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/muscle.dart';

class ExerciseDBService {
  static const String baseUrl = 'https://www.exercisedb.dev/api/v1';

  Future<List<Muscle>> getMuscles() async {
    try {
      print('Fetching muscles from API...'); // Debug
      final response = await http.get(
        Uri.parse('$baseUrl/muscles'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug
      print('Response body: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Check if response is a Map (object) or List
        if (jsonData is Map<String, dynamic>) {
          // API returns an object, check for common data keys
          if (jsonData.containsKey('data')) {
            List<dynamic> data = jsonData['data'] as List;
            return data.map((json) => Muscle.fromJson(json)).toList();
          } else if (jsonData.containsKey('muscles')) {
            List<dynamic> data = jsonData['muscles'] as List;
            return data.map((json) => Muscle.fromJson(json)).toList();
          } else if (jsonData.containsKey('results')) {
            List<dynamic> data = jsonData['results'] as List;
            return data.map((json) => Muscle.fromJson(json)).toList();
          } else {
            // The entire object might be a single muscle, wrap it in a list
            throw Exception('Unexpected API response format: ${jsonData.keys}');
          }
        } else if (jsonData is List) {
          // API returns a list directly
          return jsonData.map((json) => Muscle.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          throw Exception('Unexpected response type: ${jsonData.runtimeType}');
        }
      } else {
        throw Exception('Failed to load muscles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMuscles: $e'); // Debug
      rethrow; // Rethrow to see the full error
    }
  }
  Future<List<Exercise>> getExercisesByMuscle(String muscleName) async {
    try {
      print('Fetching exercises for muscle: $muscleName');

      final response = await http.get(
        Uri.parse('$baseUrl/muscles/${muscleName.toLowerCase()}/exercises'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        print('Response keys: ${jsonData.keys}');

        // Check for success field
        if (jsonData['success'] == true && jsonData.containsKey('data')) {
          List<dynamic> data = jsonData['data'] as List;
          print('Found ${data.length} exercises');
          return data.map((json) =>
              Exercise.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          throw Exception('API returned success: false or missing data field');
        }
      } else {
        throw Exception('Failed to load exercises: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getExercisesByMuscle: $e');
      rethrow;
    }
  }
}