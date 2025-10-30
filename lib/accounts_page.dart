// lib/accounts_page.dart

import 'package:colorown/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  // Function to handle user logout
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      // Navigate to the HomePage and remove all previous routes from the stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase Auth
    final User? user = FirebaseAuth.instance.currentUser;

    // Use a default name if the display name is not set
    final String username = user?.displayName ?? 'No username set';
    final String email = user?.email ?? 'No email found';
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // The body extends behind the app bar for a seamless background
      extendBodyBehindAppBar: true,
      // Transparent app bar to just hold the back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Manually set icon color to be visible on the dark background
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset("assets/images/rc_background.png", fit: BoxFit.cover),
          // 2. Dark Overlay
          const ColoredBox(color: Color(0x99000000)),
          // 3. Centered Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                // Max width for tablets/desktops
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
                      // Profile Icon
                      const Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Colors.tealAccent,
                      ),
                      const SizedBox(height: 16),

                      // Username
                      Text(
                        username,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email ID
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Logout Button
                      SizedBox(
                        width: 160,
                        height: 45,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE53935), Color(0xFFC62828)], // Red gradient
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _logout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: const Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
