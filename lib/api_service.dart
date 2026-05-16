import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  static const String baseUrl = 'https://gym-tracker-p09h.onrender.com/api';
  static const Duration _timeout = Duration(seconds: 10);

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  void _log(String message) {
    developer.log(message, name: 'ApiService');
    // ignore: avoid_print
    print('[ApiService] $message');
  }

  // --- Sessions ---

  Future<Session> createSession() async {
    final url = '$baseUrl/sessions';
    _log('POST $url');
    try {
      final response = await http
          .post(Uri.parse(url),
              headers: {'Content-Type': 'application/json'})
          .timeout(_timeout);

      _log('POST $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 201) {
        return Session.fromJson(jsonDecode(response.body));
      }
      throw ApiException('Failed to create session', response.statusCode);
    } catch (e) {
      _log('POST $url ERROR: $e');
      rethrow;
    }
  }

  Future<List<Session>> getSessions() async {
    final url = '$baseUrl/sessions';
    _log('GET $url');
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);

      _log('GET $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Session.fromJson(json)).toList();
      }
      throw ApiException('Failed to fetch sessions', response.statusCode);
    } catch (e) {
      _log('GET $url ERROR: $e');
      rethrow;
    }
  }

  Future<Session> getSession(int id) async {
    final url = '$baseUrl/sessions/$id';
    _log('GET $url');
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);

      _log('GET $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        return Session.fromJson(jsonDecode(response.body));
      }
      throw ApiException('Failed to fetch session', response.statusCode);
    } catch (e) {
      _log('GET $url ERROR: $e');
      rethrow;
    }
  }

  Future<Session> endSession(int id, DateTime endedAt) async {
    final url = '$baseUrl/sessions/$id';
    final body = jsonEncode({'ended_at': endedAt.toIso8601String()});
    _log('PUT $url body=$body');
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      _log('PUT $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        return Session.fromJson(jsonDecode(response.body));
      }
      throw ApiException('Failed to end session', response.statusCode);
    } catch (e) {
      _log('PUT $url ERROR: $e');
      rethrow;
    }
  }

  Future<void> deleteSession(int id) async {
    final url = '$baseUrl/sessions/$id';
    _log('DELETE $url');
    try {
      final response = await http.delete(Uri.parse(url)).timeout(_timeout);

      _log('DELETE $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode != 200) {
        throw ApiException('Failed to delete session', response.statusCode);
      }
    } catch (e) {
      _log('DELETE $url ERROR: $e');
      rethrow;
    }
  }

  // --- Exercises ---

  Future<Exercise> createExercise(int sessionId, String name) async {
    final url = '$baseUrl/sessions/$sessionId/exercises';
    final body = jsonEncode({'name': name});
    _log('POST $url body=$body');
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      _log('POST $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 201) {
        return Exercise.fromJson(jsonDecode(response.body));
      }
      throw ApiException('Failed to create exercise', response.statusCode);
    } catch (e) {
      _log('POST $url ERROR: $e');
      rethrow;
    }
  }

  Future<List<Exercise>> getExercises(int sessionId) async {
    final url = '$baseUrl/sessions/$sessionId/exercises';
    _log('GET $url');
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);

      _log('GET $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      }
      throw ApiException('Failed to fetch exercises', response.statusCode);
    } catch (e) {
      _log('GET $url ERROR: $e');
      rethrow;
    }
  }

  Future<Exercise> updateExercise(int id, String name) async {
    final url = '$baseUrl/exercises/$id';
    final body = jsonEncode({'name': name});
    _log('PUT $url body=$body');
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      _log('PUT $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        return Exercise.fromJson(jsonDecode(response.body));
      }
      throw ApiException('Failed to update exercise', response.statusCode);
    } catch (e) {
      _log('PUT $url ERROR: $e');
      rethrow;
    }
  }

  Future<void> deleteExercise(int id) async {
    final url = '$baseUrl/exercises/$id';
    _log('DELETE $url');
    try {
      final response = await http.delete(Uri.parse(url)).timeout(_timeout);

      _log('DELETE $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode != 200) {
        throw ApiException('Failed to delete exercise', response.statusCode);
      }
    } catch (e) {
      _log('DELETE $url ERROR: $e');
      rethrow;
    }
  }

  // --- Sets ---

  Future<WorkoutSet> createSet(int exerciseId, int reps, double weight) async {
    final url = '$baseUrl/exercises/$exerciseId/sets';
    final body = jsonEncode({'reps': reps, 'weight': weight});
    _log('POST $url body=$body');
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      _log('POST $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 201) {
        return WorkoutSet.fromJson(jsonDecode(response.body));
      }
      throw ApiException('Failed to create set', response.statusCode);
    } catch (e) {
      _log('POST $url ERROR: $e');
      rethrow;
    }
  }

  Future<List<WorkoutSet>> getSets(int exerciseId) async {
    final url = '$baseUrl/exercises/$exerciseId/sets';
    _log('GET $url');
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);

      _log('GET $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WorkoutSet.fromJson(json)).toList();
      }
      throw ApiException('Failed to fetch sets', response.statusCode);
    } catch (e) {
      _log('GET $url ERROR: $e');
      rethrow;
    }
  }

  Future<WorkoutSet> updateSet(int id, int reps, double weight) async {
    final url = '$baseUrl/sets/$id';
    final body = jsonEncode({'reps': reps, 'weight': weight});
    _log('PUT $url body=$body');
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(_timeout);

      _log('PUT $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        return WorkoutSet.fromJson(jsonDecode(response.body));
      }
      throw ApiException('Failed to update set', response.statusCode);
    } catch (e) {
      _log('PUT $url ERROR: $e');
      rethrow;
    }
  }

  Future<void> deleteSet(int id) async {
    final url = '$baseUrl/sets/$id';
    _log('DELETE $url');
    try {
      final response =
          await http.delete(Uri.parse(url)).timeout(_timeout);

      _log('DELETE $url → ${response.statusCode}: ${response.body}');

      if (response.statusCode != 200) {
        throw ApiException('Failed to delete set', response.statusCode);
      }
    } catch (e) {
      _log('DELETE $url ERROR: $e');
      rethrow;
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
