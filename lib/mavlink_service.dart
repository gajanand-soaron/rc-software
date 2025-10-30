import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// A simple service to communicate with your Flask backend / SITL
class MavlinkService {
  late String _serverUrl;

  final StreamController<Map<String, dynamic>> _telemetryController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get onTelemetryChanged =>
      _telemetryController.stream;

  Timer? _pollingTimer;

  /// Connect to backend
  void connect(String serverUrl) {
    _serverUrl = serverUrl;
    _startTelemetryPolling();
  }

  void disconnect() {
    _pollingTimer?.cancel();
    _telemetryController.close();
  }

  /// Poll backend every 1 second for telemetry
  void _startTelemetryPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final response = await http.get(Uri.parse("$_serverUrl/telemetry"));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          _telemetryController.add(data);
        }
      } catch (_) {
        // ignore errors for now
      }
    });
  }

  /// Send commands to backend (arm, disarm, takeoff, land, etc.)
  Future<void> sendCommand(String endpoint,
      {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$_serverUrl/$endpoint");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body ?? {}),
    );

    if (response.statusCode != 200) {
      throw Exception('Command failed: ${response.body}');
    }
  }
}
