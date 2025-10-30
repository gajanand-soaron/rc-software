import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'pre_flight_check_page.dart';
import 'arm_drone.dart';
import 'accounts_page.dart';
import 'about_device.dart';
import 'mavlink_service.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  bool _isMenuOpen = false;
  bool _isConnecting = false;
  late final String serverUrl;

  final MavlinkService _mavlinkService = MavlinkService();

  @override
  void initState() {
    super.initState();
    // Handle platform-specific URLs
    if (kIsWeb) {
      serverUrl = "http://localhost:5000"; // Flask backend for web
    } else {
      if (Platform.isAndroid) {
        serverUrl = "http://10.0.2.2:5000"; // Android emulator
      } else {
        serverUrl = "http://127.0.0.1:5000"; // iOS, macOS, desktop
      }
    }
  }

  @override
  void dispose() {
    _mavlinkService.disconnect();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  Future<void> _connect() async {
    setState(() => _isConnecting = true);

    try {
      final response = await http
          .get(Uri.parse("$serverUrl/health"))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        // Connect Mavlink service for telemetry
        _mavlinkService.connect(serverUrl);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ArmDronePage(
                serverUrl: serverUrl,
                mavlinkService: _mavlinkService,
              ),
            ),
          );
        }
      } else {
        _showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showError(
          "Connection failed: Please ensure the backend server and SITL are running.");
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Widget _menuItem(String text, IconData icon, Widget targetPage) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage));
        _toggleMenu();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
                decorationThickness: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/images/rc_background.png",
              fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          const ColoredBox(color: Color(0x99000000)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 450 ? 400 : screenWidth * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Let's connect your remote control to your drone..",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please click on "Connect" to proceed further',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 160,
                      height: 45,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF39E5B6), Color(0xFF0E74E7)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: ElevatedButton(
                          onPressed: _isConnecting ? null : _connect,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: _isConnecting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Connect",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    ConnectIcon(),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 0, top: 0),
              child: IconButton(
                icon: const Icon(Icons.menu, size: 32, color: Colors.white),
                onPressed: _toggleMenu,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10, top: 10),
                child: PopupMenuButton<int>(
                  icon: const Icon(Icons.account_circle, size: 32, color: Colors.white),
                  color: Colors.black87,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Account Settings", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AccountsPage()),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: _isMenuOpen ? 0 : -280,
            child: Material(
              color: const Color(0xFF3c3c3c),
              child: SizedBox(
                width: 280,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "User Account",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: _toggleMenu,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _menuItem("Files", Icons.description_outlined,
                            const PlaceholderPage("Files")),
                        _menuItem("3d Model", Icons.view_in_ar_outlined,
                            const PlaceholderPage("3d Model")),
                        _menuItem("Settings", Icons.settings_outlined,
                            const PlaceholderPage("Settings")),
                        _menuItem("Safety", Icons.shield_outlined,
                            const PlaceholderPage("Safety")),
                        _menuItem("Control", Icons.gamepad_outlined,
                            const PlaceholderPage("Control")),
                        _menuItem("About Device", Icons.smartphone_outlined,
                            const AboutDevicePage()),
                        _menuItem("Accounts", Icons.account_circle_outlined,
                            const AccountsPage()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("This is the $title page")),
    );
  }
}

class ConnectIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ConnectIcon({super.key, this.size = 24.0, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ConnectIconPainter(color: color),
    );
  }
}

class _ConnectIconPainter extends CustomPainter {
  final Color color;
  _ConnectIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;
    canvas.drawCircle(Offset(18 * scaleX, 18 * scaleY), 2 * scaleX, paint);
    canvas.drawCircle(Offset(6 * scaleX, 18 * scaleY), 2 * scaleX, paint);
    canvas.drawCircle(Offset(6 * scaleX, 6 * scaleY), 2 * scaleX, paint);
    canvas.drawCircle(Offset(18 * scaleX, 6 * scaleY), 2 * scaleX, paint);
    canvas.drawCircle(Offset(12 * scaleX, 12 * scaleY), 2 * scaleX, paint);
    final path = Path();
    path.moveTo(7.5 * scaleX, 7.5 * scaleY);
    path.lineTo(10.5 * scaleX, 10.5 * scaleY);
    path.moveTo(6 * scaleX, 8 * scaleY);
    path.lineTo(6 * scaleX, 16 * scaleY);
    path.moveTo(18 * scaleX, 16 * scaleY);
    path.lineTo(18 * scaleX, 8 * scaleY);
    path.moveTo(8 * scaleX, 6 * scaleY);
    path.lineTo(16 * scaleX, 6 * scaleY);
    path.moveTo(16 * scaleX, 18 * scaleY);
    path.lineTo(8 * scaleX, 18 * scaleY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
