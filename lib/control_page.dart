import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final String baseUrl = "http://YOUR_SERVER_IP:5000"; // 🔑 Replace with server IP
  bool isFlying = false;
  String statusMessage = "Disconnected";
  int altitude = 0;
  int battery = 100;

  @override
  void initState() {
    super.initState();
    _getStatus();
  }

  Future<void> _getStatus() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/status"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isFlying = data["flying"] ?? false;
          altitude = data["altitude"] ?? 0;
          battery = data["battery"] ?? 100;
          statusMessage = data["connected"] ? "Connected" : "Disconnected";
        });
      }
    } catch (e) {
      setState(() => statusMessage = "⚠️ Error getting status");
    }
  }

  Future<void> _sendCommand(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => statusMessage = data["message"]);
        _getStatus(); // refresh status
      } else {
        setState(() => statusMessage = "❌ Command failed");
      }
    } catch (e) {
      setState(() => statusMessage = "⚠️ Error: $e");
    }
  }

  Widget _controlButton(String text, IconData icon, VoidCallback onPressed,
      {Color color = Colors.blue}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drone Control"),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getStatus,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Drone status
            Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text("Status: $statusMessage",
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                    Text("Altitude: ${altitude}m",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Battery: $battery%",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Takeoff / Land buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton("Takeoff", Icons.flight_takeoff,
                    () => _sendCommand("takeoff"),
                    color: Colors.green),
                _controlButton("Land", Icons.flight_land,
                    () => _sendCommand("land"),
                    color: Colors.red),
              ],
            ),
            const SizedBox(height: 30),

            // Direction controls
            Column(
              children: [
                _controlButton("Up", Icons.arrow_upward,
                    () => _sendCommand("move", body: {"direction": "up", "speed": 5})),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _controlButton("Left", Icons.arrow_back,
                        () => _sendCommand("move", body: {"direction": "left", "speed": 5})),
                    _controlButton("Right", Icons.arrow_forward,
                        () => _sendCommand("move", body: {"direction": "right", "speed": 5})),
                  ],
                ),
                const SizedBox(height: 10),
                _controlButton("Down", Icons.arrow_downward,
                    () => _sendCommand("move", body: {"direction": "down", "speed": 5})),
              ],
            ),
            const SizedBox(height: 30),

            // Forward/Backward
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlButton("Forward", Icons.arrow_upward,
                    () => _sendCommand("move", body: {"direction": "forward", "speed": 5})),
                _controlButton("Backward", Icons.arrow_downward,
                    () => _sendCommand("move", body: {"direction": "backward", "speed": 5})),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
