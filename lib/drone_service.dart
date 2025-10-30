import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';

class DroneService {
  // --- Singleton Setup ---
  static final DroneService _instance = DroneService._internal();
  factory DroneService() => _instance;
  DroneService._internal();

  // --- Configurable ---
  String? _baseUrl; // Will be set after discovery or manually for Web

  // --- State ---
  final StreamController<Map<String, dynamic>> _statusController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;

  // -------------------- Discovery --------------------
  Future<void> discover({String? webBaseUrl}) async {
    if (kIsWeb) {
      // 🌐 Web cannot use UDP/mDNS
      if (webBaseUrl == null) {
        throw Exception("Web requires a manual LAN IP. Pass webBaseUrl parameter.");
      }
      _baseUrl = webBaseUrl;
      print("✅ Using Web LAN IP: $_baseUrl");
      return;
    }

    // Mobile/Desktop: Use mDNS
    final MDnsClient client = MDnsClient();
    await client.start();

    print("🔍 Searching for _mavsdk._tcp.local service...");
    try {
      await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer('_mavsdk._tcp.local'),
      )) {
        await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName),
        )) {
          await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(
            ResourceRecordQuery.addressIPv4(srv.target),
          )) {
            final host = ip.address.address;
            final port = srv.port;
            _baseUrl = "http://$host:$port";
            print("✅ Discovered drone at $_baseUrl");
            client.stop(); // Stop after finding
            return;
          }
        }
      }
    } catch (e) {
      client.stop();
      throw Exception("Failed to discover drone: $e");
    }
  }

  // -------------------- REST API Calls --------------------
  Future<Map<String, dynamic>?> getHealth() async {
    if (_baseUrl == null) throw Exception("Drone not discovered yet!");
    try {
      final response = await http.get(Uri.parse("$_baseUrl/health"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _statusController.add(data);
        return data;
      }
    } catch (e) {
      print("Error fetching health: $e");
    }
    return null;
  }

  Future<bool> setHome(double lat, double lon, double alt) async {
    if (_baseUrl == null) throw Exception("Drone not discovered yet!");
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/set_home?lat=$lat&lon=$lon&alt=$alt"),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error setting home: $e");
      return false;
    }
  }

  Future<bool> arm() async {
    if (_baseUrl == null) throw Exception("Drone not discovered yet!");
    try {
      final response = await http.post(Uri.parse("$_baseUrl/arm"));
      return response.statusCode == 200;
    } catch (e) {
      print("Error arming drone: $e");
      return false;
    }
  }

  Future<bool> disarm() async {
    if (_baseUrl == null) throw Exception("Drone not discovered yet!");
    try {
      final response = await http.post(Uri.parse("$_baseUrl/disarm"));
      return response.statusCode == 200;
    } catch (e) {
      print("Error disarming drone: $e");
      return false;
    }
  }

  Future<bool> takeoff([double altitude = 10.0]) async {
    if (_baseUrl == null) throw Exception("Drone not discovered yet!");
    try {
      final response = await http.post(Uri.parse("$_baseUrl/takeoff?altitude=$altitude"));
      return response.statusCode == 200;
    } catch (e) {
      print("Error takeoff: $e");
      return false;
    }
  }

  Future<bool> land() async {
    if (_baseUrl == null) throw Exception("Drone not discovered yet!");
    try {
      final response = await http.post(Uri.parse("$_baseUrl/land"));
      return response.statusCode == 200;
    } catch (e) {
      print("Error landing: $e");
      return false;
    }
  }

  void dispose() {
    _statusController.close();
  }
}
