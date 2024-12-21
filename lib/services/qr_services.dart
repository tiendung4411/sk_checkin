import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class QRServices {
  final String baseUrl = '$baseUrl1'; // Base URL for the API

  // Generate Attendance QR Code
  // Generate Attendance QR Code
  Future<Map<String, dynamic>> generateAttendanceQRCode() async {
    final url = Uri.parse('$baseUrl/generate-attendance-qr');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Return success data
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to generate QR code',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }



  Future<Map<String, dynamic>> generateGhcQRCode(String ghcId, int totalAmount) async {
    final url = Uri.parse('$baseUrl/generate-ghc-qr');
    print("Base URL: $url");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ghcId': ghcId,
          'totalAmount': totalAmount,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Return success data
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to generate QR code',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}