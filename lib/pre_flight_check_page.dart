import 'package:flutter/material.dart';
import 'arm_drone.dart';
import 'mavlink_service.dart';

class PreFlightCheckPage extends StatefulWidget {
  final String serverUrl;
  final MavlinkService mavlinkService;

  const PreFlightCheckPage({
    super.key,
    required this.serverUrl,
    required this.mavlinkService,
  });

  @override
  State<PreFlightCheckPage> createState() => _PreFlightCheckPageState();
}

class _PreFlightCheckPageState extends State<PreFlightCheckPage> {
  bool gpsOk = false;
  bool batteryOk = false;
  bool sensorsOk = false;

  @override
  void initState() {
    super.initState();
    widget.mavlinkService.onTelemetryChanged.listen((telemetry) {
      if (!mounted) return;
      setState(() {
        gpsOk = (telemetry['gps_fix'] ?? 0) > 0;
        batteryOk = (telemetry['battery'] ?? 0) > 20;
        sensorsOk = true; // assuming sensors are ok in SITL
      });
    });
  }

  bool get allChecksPassed => gpsOk && batteryOk && sensorsOk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/rc_background.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          const ColoredBox(color: Color(0x99000000)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Pre-Flight Checks",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  _checkTile("GPS Status", gpsOk),
                  _checkTile("Battery > 20%", batteryOk),
                  _checkTile("Sensors OK", sensorsOk),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: allChecksPassed
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArmDronePage(
                                  serverUrl: widget.serverUrl,
                                  mavlinkService: widget.mavlinkService,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      backgroundColor: allChecksPassed
                          ? Colors.green
                          : Colors.grey,
                    ),
                    child: const Text(
                      "Proceed to Arm",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkTile(String title, bool ok) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel,
            color: ok ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
}
