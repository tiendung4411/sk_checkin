import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class GHCServices {
  final String baseUrl = '$baseUrl1';

  // Fetch GHC list by owner ID
  Future<Map<String, dynamic>> fetchGHCsByOwner(String ownerId) async {
    final url = Uri.parse('$baseUrl/ghc/owner/$ownerId');
    print("Base URL on GHC: $url");
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        return json.decode(response.body); // Return success data
      } else {
        final errorData = json.decode(response.body);
        print("Error Data: $errorData");
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch GHC list',
        };
      }
    } catch (e) {
      print("Error in fetchGHCsByOwner: $e");
      return {

        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}