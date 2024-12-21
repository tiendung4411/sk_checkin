import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class UserService {
  final String baseUrl = '$baseUrl1/users';
  Future<Map<String, dynamic>> loginUser(Map<String, String> credentials) async {
    final url = Uri.parse('$baseUrl/login');
    print("baseUrl: $baseUrl");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(credentials),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Return decoded JSON directly
      } else {
        final errorData = json.decode(response.body);
        // More descriptive error message
        final errorMessage = errorData['message'] ?? 'Login failed';
        return {'success': false, 'message': errorMessage , 'statusCode': response.statusCode};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  // Create a new user (Sign Up)
  Future<Map<String, dynamic>> createUser(Map<String, String> userData) async {
    final url = Uri.parse('$baseUrl/users');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'message': json.decode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get all users
  Future<Map<String, dynamic>> getAllUsers() async {
    final url = Uri.parse('$baseUrl/users');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)['data']};
      } else {
        return {'success': false, 'message': json.decode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    final url = Uri.parse('$baseUrl/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Raw Response Body: ${response.body}"); // Debug print
        return {'success': true, 'data': json.decode(response.body)['data']};
      } else {
        print("Raw Response Body: ${response.body}"); // Debug print
        return {'success': false, 'message': json.decode(response.body)['message']};
      }
    } catch (e) {
      print("catch error: $e"); // Debug print
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUser(String userId, Map<String, String> updatedData) async {
    final url = Uri.parse('$baseUrl/users/$userId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)['data']};
      } else {
        return {'success': false, 'message': json.decode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete a user
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'User deleted successfully'};
      } else {
        return {'success': false, 'message': json.decode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update user points
  Future<Map<String, dynamic>> updateUserPoints(String userId, int points) async {
    final url = Uri.parse('$baseUrl/users/$userId/points');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'points': points}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)['data']};
      } else {
        return {'success': false, 'message': json.decode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
