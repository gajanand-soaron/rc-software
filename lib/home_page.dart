import 'dart:math'; // ✅ Imported to use the min() function for cleaner code.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the actual page files.
import 'login_page.dart';
import 'connect_page.dart';

// Import the separated widget files.
import 'widgets/custom_appbar.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder provides the parent widget's constraints, which is the key
    // to creating a truly responsive UI that adapts to any screen size.
    return LayoutBuilder(
      builder: (context, constraints) {
        // We define the original design dimensions to calculate scaling factors.
        // This acts as our baseline for all responsive calculations.
        const double designWidth = 744;
        const double designHeight = 528;

        // Calculate the raw scaling ratios for width and height.
        final double widthScale = constraints.maxWidth / designWidth;
        final double heightScale = constraints.maxHeight / designHeight;

        // ✅ Use the smaller of the two scale factors to maintain aspect ratio.
        // ✅ We also clamp the scale factor to a reasonable range (e.g., 0.8 to 1.5).
        // This prevents UI elements from becoming too tiny or excessively large on extreme screen sizes.
        final double scaleFactor = min(widthScale, heightScale).clamp(0.8, 1.5);

        // A simple helper function to apply the final scale factor.
        double scale(double value) => value * scaleFactor;
        
        // ✅ Determine if the screen is wider than it is tall (e.g., landscape or tablet).
        // We can use this to make layout decisions.
        final bool isWideScreen = constraints.maxWidth > constraints.maxHeight;

        return Scaffold(
          appBar: const CustomAppBar(),
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image
              Image.asset(
                "assets/images/rc_background.png",
                fit: BoxFit.cover,
              ),

              // 2. Semi-transparent Black Overlay
              const ColoredBox(color: Color(0x99000000)),

              // 3. Main content, now aware of the screen's aspect ratio.
              _buildContent(context, scale, isWideScreen),
            ],
          ),
        );
      },
    );
  }

  /// Builds the main content of the page, scaled for responsiveness.
  Widget _buildContent(BuildContext context, double Function(double) scale, bool isWideScreen) {
    // SafeArea ensures the content is not obscured by system UI like notches or status bars.
    return SafeArea(
      child: Padding(
        // Responsive horizontal padding.
        padding: EdgeInsets.symmetric(horizontal: scale(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Spacer flex values are adjusted based on the screen's aspect ratio
            // to improve the layout in landscape mode.
            Spacer(flex: isWideScreen ? 1 : 2),

            // "Welcome to Colorown" Text and Line
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Welcome to Colorown",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: scale(32),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: scale(12)),
                  Container(
                    height: 2,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ],
              ),
            ),

            SizedBox(height: scale(12)),

            // "Let's Watch..." Text
            Text(
              "Let's Watch Tutorial before stepping In",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: scale(18),
              ),
            ),
            SizedBox(height: scale(48)),

            // "Watch Tutorial" Button
            SizedBox(
              width: scale(203),
              height: scale(42),
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement tutorial video functionality.
                  // For now, it navigates to the login page as a placeholder.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF39E5B6), width: 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: scale(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Watch Tutorial", style: TextStyle(fontSize: scale(16))),
                    SizedBox(width: scale(8)),
                    TutorialIcon(size: scale(24)),
                  ],
                ),
              ),
            ),
            
            // ✅ This spacer also adjusts its flex for better landscape layout.
            Spacer(flex: isWideScreen ? 2 : 3),

            // Bottom Row for "Step In" and "Skip"
            Padding(
              padding: EdgeInsets.only(bottom: scale(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "Step In" Button with Gradient
                  SizedBox(
                    width: scale(148),
                    height: scale(42),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(57, 229, 182, 0.5),
                            Color.fromRGBO(14, 116, 231, 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: ElevatedButton(
                        onPressed: () => _navigateToNextPage(context), // ✅ Implemented
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(21),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Step In",
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: scale(16),
                                height: 1.5,
                              ),
                            ),
                            SizedBox(width: scale(8)),
                            WalkIcon(size: scale(24)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // "Skip" Button
                  TextButton(
                    onPressed: () => _navigateToNextPage(context), // ✅ Implemented
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: scale(16),
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Extracted navigation logic into a reusable method.
  /// Checks auth state and navigates to the appropriate page (ConnectPage or LoginPage).
  void _navigateToNextPage(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user is logged in, go to the connect page.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConnectPage()),
      );
    } else {
      // If user is not logged in, go to the login page.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}


// --- Custom SVG Icon Widgets ---
// (These are already responsive and require no changes)

class WalkIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WalkIcon({super.key, this.size = 24.0, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WalkIconPainter(color: color),
    );
  }
}

class _WalkIconPainter extends CustomPainter {
  final Color color;
  _WalkIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;

    canvas.drawCircle(Offset(13 * scaleX, 4 * scaleY), 1 * scaleX, paint);
    path.moveTo(7 * scaleX, 21 * scaleY);
    path.lineTo(10 * scaleX, 17 * scaleY);
    path.moveTo(16 * scaleX, 21 * scaleY);
    path.lineTo(14 * scaleX, 17 * scaleY);
    path.lineTo(11 * scaleX, 14 * scaleY);
    path.lineTo(12 * scaleX, 8 * scaleY);
    path.moveTo(6 * scaleX, 12 * scaleY);
    path.lineTo(8 * scaleX, 9 * scaleY);
    path.lineTo(12 * scaleX, 8 * scaleY);
    path.lineTo(15 * scaleX, 11 * scaleY);
    path.lineTo(18 * scaleX, 12 * scaleY);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class TutorialIcon extends StatelessWidget {
  final double size;
  final Color color;

  const TutorialIcon({super.key, this.size = 24.0, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TutorialIconPainter(color: color),
    );
  }
}

class _TutorialIconPainter extends CustomPainter {
  final Color color;
  _TutorialIconPainter({required this.color});

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

    final path = Path();

    final rect = Rect.fromLTRB(3 * scaleX, 6 * scaleY, 21 * scaleX, 20 * scaleY);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(4 * scaleX));
    path.addRRect(rrect);

    path.moveTo(8 * scaleX, 3 * scaleY);
    path.lineTo(10 * scaleX, 6 * scaleY);
    path.moveTo(16 * scaleX, 3 * scaleY);
    path.lineTo(14 * scaleX, 6 * scaleY);
    path.moveTo(9 * scaleX, 13 * scaleY);
    path.lineTo(9 * scaleX, 11 * scaleY);
    path.moveTo(15 * scaleX, 11 * scaleY);
    path.lineTo(15 * scaleX, 13 * scaleY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}