import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants.dart';

class ApiService {
  final String baseUrl = '$baseUrl1'; // Replace with your actual base API URL
  late IO.Socket socket;

  // Map to track listeners for each event
  final Map<String, List<Function>> _listeners = {};

  ApiService() {
    _initSocket();
  }

  // Initialize Socket.IO
  void _initSocket() {
    socket = IO.io('http://192.168.100.108:3201', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.on('connect', (_) {
      print('Connected to Socket.IO server');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from Socket.IO server');
    });

    socket.connect();
  }

  // Send data via Socket.IO
  void sendMessage(String event, dynamic data) {
    socket.emit(event, data);
  }

  // Listen to a specific event
  void listenToEvent(String event, Function(dynamic) callback) {
    // Add listener to the internal tracking map
    _listeners.putIfAbsent(event, () => []);
    _listeners[event]!.add(callback);

    // Add listener to Socket.IO
    socket.on(event, (data) {
      for (var listener in _listeners[event]!) {
        listener(data);
      }
    });
  }

  // Remove a specific listener for an event
  void removeListener(String event, Function(dynamic) callback) {
    if (_listeners.containsKey(event)) {
      _listeners[event]!.remove(callback);
      if (_listeners[event]!.isEmpty) {
        socket.off(event);
        _listeners.remove(event);
      }
    }
  }

  // Remove all listeners for an event
  void removeAllListeners(String event) {
    if (_listeners.containsKey(event)) {
      socket.off(event);
      _listeners.remove(event);
    }
  }

  // Remove all listeners for all events
  void clearAllListeners() {
    for (var event in _listeners.keys) {
      socket.off(event);
    }
    _listeners.clear();
  }

  // HTTP GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error in GET request: $e');
      throw Exception('Error in GET request: $e');
    }
  }

  // HTTP POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      print('Error in POST request: $e');
      throw Exception('Error in POST request: $e');
    }
  }

  // Check if socket is connected
  bool isSocketConnected() {
    return socket.connected;
  }

  // Disconnect from socket and clear all listeners
  void disconnectSocket() {
    clearAllListeners();
    socket.disconnect();
  }

  Future<void> emitCongratulateSignal(String roundId) async {
    try {
      socket.emit('triggerCongratulationAnimation', {'roundId': roundId}); // Emit the correct event
      print('Congratulate signal emitted for roundId: $roundId');
    } catch (e) {
      print('Error emitting congratulate signal: $e');
    }
  }
}