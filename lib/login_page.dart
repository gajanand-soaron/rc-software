import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:colorown/widgets/custom_appbar.dart'; // Assuming this path is correct
import 'package:colorown/connect_page.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConnectPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "An unknown error occurred.";
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        message = "Incorrect email or password provided.";
      } else if (e.code == 'wrong-password') {
        message = "The password provided is incorrect.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is not valid.";
      }
      _showErrorDialog(message);
    } catch (e) {
      _showErrorDialog("An unexpected error occurred. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    _animationController.reset();
    _animationController.forward();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.redAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    "Login Failed",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text("TRY AGAIN"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/rc_background.png", fit: BoxFit.cover),
          const ColoredBox(color: Color(0x99000000)), // Background overlay
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth > 450 ? 400 : screenWidth * 0.9,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xE53C4048),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.tealAccent, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title and close button
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const Center(
                              child: Text(
                                "Login to Colorown",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomePage()),
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Email
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Enter email address"),
                        ),
                        const SizedBox(height: 15),

                        // Password and Forgot Password
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration("Password").copyWith(
                                suffixIcon: IconButton(
                                  icon: EyeIcon(
                                    color: _obscurePassword ? Colors.white70 : Colors.tealAccent,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password logic
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Login button
                        SizedBox(
                          width: 148,
                          height: 42,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Login", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 8),
                                        LoginIcon(),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Signup link
                        Column(
                          children: [
                            const Text(
                               "Don’t have an account?",
                               style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const SignupPage()),
                              ),
                              child: const Text(
                                "Signup",
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.greenAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1E1E1E), // Darker input field
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.tealAccent, width: 1.5),
      ),
    );
  }
}

// --- Custom SVG Icon Widgets ---

class EyeIcon extends StatelessWidget {
  final Color color;
  const EyeIcon({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _EyeIconPainter(color: color),
    );
  }
}

class _EyeIconPainter extends CustomPainter {
  final Color color;
  _EyeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.25
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 20.0;
    final scaleY = size.height / 20.0;

    final path = Path();
    
    path.addOval(Rect.fromCircle(center: Offset(10 * scaleX, 10 * scaleY), radius: 1.6667 * scaleX));
    path.moveTo(17.5 * scaleX, 10 * scaleY);
    path.cubicTo(15.5 * scaleX, 13.3333 * scaleY, 13 * scaleX, 15 * scaleY, 10 * scaleX, 15 * scaleY);
    path.cubicTo(7 * scaleX, 15 * scaleY, 4.5 * scaleX, 13.3333 * scaleY, 2.5 * scaleX, 10 * scaleY);
    path.cubicTo(4.5 * scaleX, 6.66667 * scaleY, 7 * scaleX, 5 * scaleY, 10 * scaleX, 5 * scaleY);
    path.cubicTo(13 * scaleX, 5 * scaleY, 15.5 * scaleX, 6.66667 * scaleY, 17.5 * scaleX, 10 * scaleY);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginIcon extends StatelessWidget {
  const LoginIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 24),
      painter: _LoginIconPainter(),
    );
  }
}

class _LoginIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scaleX = size.width / 24.0;
    final scaleY = size.height / 24.0;

    final path = Path();

    path.moveTo(15 * scaleX, 8 * scaleY);
    path.lineTo(15 * scaleX, 6 * scaleY);
    path.cubicTo(15 * scaleX, 4.21071 * scaleY, 13.5304 * scaleX, 4 * scaleY, 13 * scaleX, 4 * scaleY);
    path.lineTo(6 * scaleX, 4 * scaleY);
    path.cubicTo(4.21071 * scaleX, 4 * scaleY, 4 * scaleX, 5.46957 * scaleY, 4 * scaleX, 6 * scaleY);
    path.lineTo(4 * scaleX, 18 * scaleY);
    path.cubicTo(4 * scaleX, 19.7893 * scaleY, 5.46957 * scaleX, 20 * scaleY, 6 * scaleX, 20 * scaleY);
    path.lineTo(13 * scaleX, 20 * scaleY);
    path.cubicTo(14.7893 * scaleX, 20 * scaleY, 15 * scaleX, 18.5304 * scaleY, 15 * scaleX, 18 * scaleY);
    path.lineTo(15 * scaleX, 16 * scaleY);
    path.moveTo(21 * scaleX, 12 * scaleY);
    path.lineTo(8 * scaleX, 12 * scaleY);
    path.lineTo(11 * scaleX, 9 * scaleY);
    path.moveTo(11 * scaleX, 15 * scaleY);
    path.lineTo(8 * scaleX, 12 * scaleY);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

