import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'dart:async';

class RemoteControlPage extends StatefulWidget {
  const RemoteControlPage({super.key});

  @override
  State<RemoteControlPage> createState() => _RemoteControlPageState();
}

class _RemoteControlPageState extends State<RemoteControlPage> {
  final String serverUrl = "http://127.0.0.1:5000"; // change IP for your server
  Map<String, dynamic> telemetry = {};
  Timer? telemetryTimer;

  @override
  void initState() {
    super.initState();
    // fetch telemetry every 2 seconds
    telemetryTimer = Timer.periodic(const Duration(seconds: 2), (_) => fetchTelemetry());
  }

  @override
  void dispose() {
    telemetryTimer?.cancel();
    super.dispose();
  }

  Future<void> sendChannel(int ch, int value) async {
    await http.post(
      Uri.parse("$serverUrl/rc_override"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({ch.toString(): value}),
    );
  }

  void handleJoystick(String axis, double x, double y) {
    int pwmX = (1500 + x * 500).toInt();
    int pwmY = (1500 + y * 500).toInt();

    if (axis == "roll") sendChannel(2, pwmX);
    if (axis == "pitch") sendChannel(3, pwmY);
    if (axis == "yaw") sendChannel(4, pwmX);
    if (axis == "throttle") sendChannel(1, pwmY);
  }

  Widget buildSwitch(String label, int channel) {
    return Row(
      children: [
        Text(label),
        Switch(
          value: false,
          onChanged: (val) {
            int pwm = val ? 2000 : 1000;
            sendChannel(channel, pwm);
          },
        ),
      ],
    );
  }

  Widget buildSlider(String label, int channel) {
    return Column(
      children: [
        Text(label),
        Slider(
          min: 1000,
          max: 2000,
          value: 1500,
          onChanged: (val) {
            sendChannel(channel, val.toInt());
          },
        ),
      ],
    );
  }

  Future<void> fetchTelemetry() async {
    try {
      final response = await http.get(Uri.parse("$serverUrl/telemetry"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "ok") {
          setState(() {
            telemetry = data["telemetry"];
          });
        }
      }
    } catch (e) {
      debugPrint("Telemetry fetch failed: $e");
    }
  }

  Widget telemetryPanel() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Telemetry", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Battery: ${telemetry["battery_voltage"] ?? "--"} V (${telemetry["battery_remaining"] ?? "--"}%)"),
            Text("Altitude: ${telemetry["altitude"] ?? "--"} m"),
            Text("Airspeed: ${telemetry["airspeed"] ?? "--"} m/s"),
            Text("Groundspeed: ${telemetry["groundspeed"] ?? "--"} m/s"),
            Text("Heading: ${telemetry["heading"] ?? "--"}°"),
            Text("GPS Fix: ${telemetry["gps_fix"] ?? "--"} (${telemetry["satellites_visible"] ?? "--"} sats)"),
            Text("Mode: ${telemetry["mode"] ?? "--"}"),
            Text("Armed: ${telemetry["armed"] ?? "--"}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Drone Remote Control")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            telemetryPanel(),
            const Text("Joysticks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("Throttle"),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Joystick(
                        mode: JoystickMode.vertical,
                        listener: (details) => handleJoystick("throttle", details.x, details.y),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text("Yaw"),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Joystick(
                        mode: JoystickMode.horizontal,
                        listener: (details) => handleJoystick("yaw", details.x, details.y),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("Roll"),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Joystick(
                        mode: JoystickMode.horizontal,
                        listener: (details) => handleJoystick("roll", details.x, details.y),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text("Pitch"),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Joystick(
                        mode: JoystickMode.vertical,
                        listener: (details) => handleJoystick("pitch", details.x, details.y),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const Text("Switches", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildSwitch("RTL Mode (CH5)", 5),
            buildSwitch("Loiter Mode (CH6)", 6),
            buildSwitch("Altitude Hold (CH7)", 7),
            buildSwitch("Land (CH9)", 9),
            buildSwitch("Auto Mode (CH10)", 10),
            buildSwitch("Programmable Switch (CH11)", 11),
            const Divider(),
            const Text("Sliders (Pots)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            buildSlider("Arm/Disarm (CH8)", 8),
            buildSlider("Programmable Pot (CH12)", 12),
            buildSlider("Programmable Pot (CH13)", 13),
            buildSlider("Programmable Pot (CH14)", 14),
          ],
        ),
      ),
    );
  }
}
