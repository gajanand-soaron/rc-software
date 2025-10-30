import 'package:flutter/material.dart';
import 'drone_service.dart';
import 'arm_drone_page.dart'; // Next page after home is set

class SetHomePage extends StatefulWidget {
  const SetHomePage({super.key});

  @override
  State<SetHomePage> createState() => _SetHomePageState();
}

class _SetHomePageState extends State<SetHomePage> {
  final DroneService _droneService = DroneService();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  final TextEditingController _altController = TextEditingController(text: "10.0");

  bool _isSettingHome = false;
  String? _errorMessage;

  Future<void> _setHome() async {
    final lat = double.tryParse(_latController.text);
    final lon = double.tryParse(_lonController.text);
    final alt = double.tryParse(_altController.text);

    if (lat == null || lon == null || alt == null) {
      setState(() {
        _errorMessage = "Please enter valid numbers for latitude, longitude, and altitude.";
      });
      return;
    }

    setState(() {
      _isSettingHome = true;
      _errorMessage = null;
    });

    try {
      final success = await _droneService.setHome(lat, lon, alt);
      if (success) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ArmDronePage()),
          );
        }
      } else {
        setState(() {
          _errorMessage = "Failed to set home. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error setting home: $e";
      });
    } finally {
      setState(() {
        _isSettingHome = false;
      });
    }
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0x991F2A37),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/rc_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
              decoration: BoxDecoration(
                color: const Color(0xCC1F2A37),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00BFA5).withOpacity(0.8), width: 1.5),
              ),
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Set Home Position",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter Latitude, Longitude, and Altitude for the home position",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  _buildInputField("Latitude (°)", _latController),
                  _buildInputField("Longitude (°)", _lonController),
                  _buildInputField("Altitude (m)", _altController),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                    ),

                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _isSettingHome
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFF39E5B6), Color(0xFF0E74E7)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        color: _isSettingHome ? Colors.grey[800] : null,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: _isSettingHome ? null : _setHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isSettingHome
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Set Home",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.home, color: Colors.white),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
