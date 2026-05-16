import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  static const String baseUrl = 'https://gym-tracker-backend.onrender.com/api';
  static const Duration _timeout = Duration(seconds: 10);

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // --- Sessions ---

  Future<Session> createSession() async {
    final response = await http
        .post(Uri.parse('$baseUrl/sessions'),
            headers: {'Content-Type': 'application/json'})
        .timeout(_timeout);

    if (response.statusCode == 201) {
      return Session.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to create session', response.statusCode);
  }

  Future<List<Session>> getSessions() async {
    final response =
        await http.get(Uri.parse('$baseUrl/sessions')).timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Session.fromJson(json)).toList();
    }
    throw ApiException('Failed to fetch sessions', response.statusCode);
  }

  Future<Session> getSession(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/sessions/$id')).timeout(_timeout);

    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to fetch session', response.statusCode);
  }

  Future<Session> endSession(int id, DateTime endedAt) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/sessions/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'ended_at': endedAt.toIso8601String()}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to end session', response.statusCode);
  }

  Future<void> deleteSession(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/sessions/$id'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ApiException('Failed to delete session', response.statusCode);
    }
  }

  // --- Exercises ---

  Future<Exercise> createExercise(int sessionId, String name) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/sessions/$sessionId/exercises'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name}),
        )
        .timeout(_timeout);

    if (response.statusCode == 201) {
      return Exercise.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to create exercise', response.statusCode);
  }

  Future<List<Exercise>> getExercises(int sessionId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/sessions/$sessionId/exercises'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Exercise.fromJson(json)).toList();
    }
    throw ApiException('Failed to fetch exercises', response.statusCode);
  }

  Future<Exercise> updateExercise(int id, String name) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/exercises/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return Exercise.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to update exercise', response.statusCode);
  }

  Future<void> deleteExercise(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/exercises/$id'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ApiException('Failed to delete exercise', response.statusCode);
    }
  }

  // --- Sets ---

  Future<WorkoutSet> createSet(int exerciseId, int reps, double weight) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/exercises/$exerciseId/sets'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'reps': reps, 'weight': weight}),
        )
        .timeout(_timeout);

    if (response.statusCode == 201) {
      return WorkoutSet.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to create set', response.statusCode);
  }

  Future<List<WorkoutSet>> getSets(int exerciseId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/exercises/$exerciseId/sets'))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WorkoutSet.fromJson(json)).toList();
    }
    throw ApiException('Failed to fetch sets', response.statusCode);
  }

  Future<WorkoutSet> updateSet(int id, int reps, double weight) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/sets/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'reps': reps, 'weight': weight}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return WorkoutSet.fromJson(jsonDecode(response.body));
    }
    throw ApiException('Failed to update set', response.statusCode);
  }

  Future<void> deleteSet(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/sets/$id')).timeout(_timeout);

    if (response.statusCode != 200) {
      throw ApiException('Failed to delete set', response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
