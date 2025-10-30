import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  // Made scale optional to allow usage in pages without scaling logic.
  final double Function(double)? scale;
  const CustomAppBar({super.key, this.scale});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  // Provide a default scale function if one isn't passed.
  Size get preferredSize => Size.fromHeight((scale ?? (d) => d)(40));
}

class _CustomAppBarState extends State<CustomAppBar> {
  String _timeString = '';
  String _dateString = '';
  int _batteryLevel = 100;
  bool _wifiOn = false;

  final Battery _battery = Battery();
  StreamSubscription? _batterySub;
  StreamSubscription? _connectivitySub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());

    _initBattery();
    _initConnectivity();
  }

  void _updateDateTime() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _timeString = DateFormat('h:mm').format(now); // e.g. 9:41
      _dateString = DateFormat('EEE MMM d').format(now); // e.g. Mon Jun 22
    });
  }

  void _initBattery() async {
    if (!mounted) return;
    _batteryLevel = await _battery.batteryLevel;
    setState(() {});
    _batterySub = _battery.onBatteryStateChanged.listen((_) async {
      if (!mounted) return;
      _batteryLevel = await _battery.batteryLevel;
      setState(() {});
    });
  }

  // Updated to handle the latest connectivity_plus version
  void _initConnectivity() async {
    if (!mounted) return;
    final result = await Connectivity().checkConnectivity();
    _updateWifiState(result);
    _connectivitySub = Connectivity().onConnectivityChanged.listen(_updateWifiState);
  }

  // Updated to accept a List<ConnectivityResult>
  void _updateWifiState(List<ConnectivityResult> result) {
    if (!mounted) return;
    // Check if the list of connections contains wifi
    setState(() => _wifiOn = result.contains(ConnectivityResult.wifi));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _batterySub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the provided scale function, or a default one if it's null.
    final scale = widget.scale ?? (double value) => value;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Left side: Time + Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _timeString,
                style: TextStyle(
                    color: Colors.white, fontSize: scale(14), fontWeight: FontWeight.w500),
              ),
              SizedBox(width: scale(8)),
              Text(
                _dateString,
                style: TextStyle(color: Colors.white, fontSize: scale(14)),
              ),
            ],
          ),

          /// Right side: Wi-Fi + Battery
          Row(
            children: [
              WifiIcon(
                size: scale(16),
                color: _wifiOn ? Colors.white : Colors.grey.withOpacity(0.6),
              ),
              SizedBox(width: scale(8)),
              Text(
                "$_batteryLevel%",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: scale(14),
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(width: scale(4)),
              BatteryIcon(
                size: scale(26),
                level: _batteryLevel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WifiIcon extends StatelessWidget {
  final double size;
  final Color color;
  const WifiIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * (11 / 16)), // maintain aspect ratio
      painter: _WifiIconPainter(color: color),
    );
  }
}

class _WifiIconPainter extends CustomPainter {
  final Color color;
  _WifiIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 15.055; // SVG width
    final scaleY = size.height / 10.778; // SVG height

    final path = Path();
    path.moveTo(13.4773 * scaleX, 4.99588 * scaleY);
    path.cubicTo(13.5908 * scaleX, 5.10238 * scaleY, 13.7658 * scaleX, 5.10288 * scaleY, 13.8763 * scaleX, 4.99288 * scaleY);
    path.lineTo(14.9403 * scaleX, 3.92888 * scaleY);
    path.cubicTo(15.0548 * scaleX, 3.81388 * scaleY, 15.0553 * scaleX, 3.62438 * scaleY, 14.9373 * scaleX, 3.51288 * scaleY);
    path.cubicTo(13.1283 * scaleX, 1.80038 * scaleY, 10.6868 * scaleX, 0.749878 * scaleY, 7.99935 * scaleX, 0.749878 * scaleY);
    path.cubicTo(5.31185 * scaleX, 0.749878 * scaleY, 2.87035 * scaleX, 1.80038 * scaleY, 1.06135 * scaleX, 3.51288 * scaleY);
    path.cubicTo(0.943346 * scaleX, 3.62438 * scaleY, 0.943846 * scaleX, 3.81388 * scaleY, 1.05835 * scaleX, 3.92888 * scaleY);
    path.lineTo(2.12235 * scaleX, 4.99288 * scaleY);
    path.cubicTo(2.23285 * scaleX, 5.10288 * scaleY, 2.40785 * scaleX, 5.10238 * scaleY, 2.52135 * scaleX, 4.99588 * scaleY);
    path.cubicTo(3.95585 * scaleX, 3.65138 * scaleY, 5.88285 * scaleX, 2.82688 * scaleY, 7.99935 * scaleX, 2.82688 * scaleY);
    path.cubicTo(10.1158 * scaleX, 2.82688 * scaleY, 12.0428 * scaleX, 3.65138 * scaleY, 13.4773 * scaleX, 4.99588 * scaleY);
    path.close();
    path.moveTo(11.0305 * scaleX, 7.44633 * scaleY);
    path.cubicTo(11.146 * scaleX, 7.54933 * scaleY, 11.3185 * scaleX, 7.55033 * scaleY, 11.428 * scaleX, 7.44083 * scaleY);
    path.lineTo(12.4905 * scaleX, 6.37833 * scaleY);
    path.cubicTo(12.606 * scaleX, 6.26283 * scaleY, 12.6065 * scaleX, 6.07033 * scaleY, 12.4865 * scaleX, 5.95983 * scaleY);
    path.cubicTo(11.3055 * scaleX, 4.87433 * scaleY, 9.72997 * scaleX, 4.21133 * scaleY, 7.99947 * scaleX, 4.21133 * scaleY);
    path.cubicTo(6.26897 * scaleX, 4.21133 * scaleY, 4.69347 * scaleX, 4.87433 * scaleY, 3.51247 * scaleX, 5.95983 * scaleY);
    path.cubicTo(3.39247 * scaleX, 6.07033 * scaleY, 3.39297 * scaleX, 6.26283 * scaleY, 3.50847 * scaleX, 6.37833 * scaleY);
    path.lineTo(4.57097 * scaleX, 7.44083 * scaleY);
    path.cubicTo(4.68047 * scaleX, 7.55033 * scaleY, 4.85297 * scaleX, 7.54933 * scaleY, 4.96847 * scaleX, 7.44633 * scaleY);
    path.cubicTo(5.77447 * scaleX, 6.72683 * scaleY, 6.83647 * scaleX, 6.28833 * scaleY, 7.99947 * scaleX, 6.28833 * scaleY);
    path.cubicTo(9.16247 * scaleX, 6.28833 * scaleY, 10.2245 * scaleX, 6.72683 * scaleY, 11.0305 * scaleX, 7.44633 * scaleY);
    path.close();
    path.moveTo(10.0343 * scaleX, 8.41098 * scaleY);
    path.cubicTo(10.1598 * scaleX, 8.51598 * scaleY, 10.1588 * scaleX, 8.71148 * scaleY, 10.0428 * scaleX, 8.82748 * scaleY);
    path.lineTo(8.20482 * scaleX, 10.6655 * scaleY);
    path.cubicTo(8.09232 * scaleX, 10.778 * scaleY, 7.90932 * scaleX, 10.778 * scaleY, 7.79682 * scaleX, 10.6655 * scaleY);
    path.lineTo(5.95882 * scaleX, 8.82748 * scaleY);
    path.cubicTo(5.84282 * scaleX, 8.71148 * scaleY, 5.84132 * scaleX, 8.51598 * scaleY, 5.96732 * scaleX, 8.41098 * scaleY);
    path.cubicTo(6.51782 * scaleX, 7.95048 * scaleY, 7.22682 * scaleX, 7.67298 * scaleY, 8.00082 * scaleX, 7.67298 * scaleY);
    path.cubicTo(8.77482 * scaleX, 7.67298 * scaleY, 9.48332 * scaleX, 7.95048 * scaleY, 10.0343 * scaleX, 8.41098 * scaleY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BatteryIcon extends StatelessWidget {
  final double size;
  final int level;
  const BatteryIcon({super.key, required this.size, required this.level});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * (12 / 28)), // maintain aspect ratio
      painter: _BatteryIconPainter(level: level),
    );
  }
}

class _BatteryIconPainter extends CustomPainter {
  final int level;
  _BatteryIconPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final bodyWidth = size.width * 0.9;
    final bodyHeight = size.height;
    
    // Draw battery body (outline)
    final bodyRect = Rect.fromLTWH(0, 0, bodyWidth, bodyHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)), outlinePaint);
    
    // Draw battery tip
    final tipRect = Rect.fromLTWH(bodyWidth, bodyHeight * 0.25, size.width * 0.1, bodyHeight * 0.5);
    canvas.drawRRect(RRect.fromRectAndRadius(tipRect, const Radius.circular(1)), outlinePaint);

    // Draw fill level
    if (level > 0) {
      final fillWidth = (bodyWidth * 0.95) * (level / 100);
      final fillRect = Rect.fromLTWH(bodyWidth * 0.025, bodyHeight * 0.1, fillWidth, bodyHeight * 0.8);
       canvas.drawRRect(RRect.fromRectAndRadius(fillRect, const Radius.circular(2)), fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BatteryIconPainter oldDelegate) {
    return oldDelegate.level != level;
  }
}

