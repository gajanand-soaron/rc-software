import 'package:flutter/material.dart';

class AboutDevicePage extends StatelessWidget {
  const AboutDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get screen width to calculate scaling factor for UI elements.
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ Define a scale factor based on a standard mobile screen width (e.g., 375).
    // This allows UI elements like fonts and padding to scale proportionally.
    final double scaleFactor = screenWidth / 375;

    return Scaffold(
      body: Stack(
        children: [
          // Universal background image
          Image.asset(
            "assets/images/rc_background.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Slight overlay
          Container(color: Colors.black.withOpacity(0.35)),

          // Dialog-style centered box
          Center(
            // ✅ Use ConstrainedBox to set a maximum width.
            // This prevents the dialog from becoming too wide on tablets or desktops.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Container(
                // Use a percentage of the screen width, which is capped by the ConstrainedBox.
                width: screenWidth * 0.9,
                // ✅ Make padding responsive using the scale factor.
                padding: EdgeInsets.all(20 * scaleFactor),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.tealAccent, width: 2),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    // ✅ Make the column only as tall as its children.
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Row (About Device + Close button)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "About Device",
                            style: TextStyle(
                              // ✅ Responsive font size with clamping to prevent it from getting too big or small.
                              fontSize: (20 * scaleFactor).clamp(18.0, 24.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      // ✅ Responsive spacing.
                      SizedBox(height: 12 * scaleFactor),

                      // Product Name
                      Text(
                        "Product Name: Colorown Drone Remote Control ID",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10 * scaleFactor),

                      Text(
                        "The Colorown Paint Drone Remote Control is a cutting-edge device designed "
                        "to control a specialized drone capable of painting large-scale structures "
                        "with precision and efficiency. This revolutionary product is a game-changer "
                        "in the field of construction and maintenance, offering a host of features "
                        "that make it an invaluable tool for architectural and engineering projects.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 20 * scaleFactor),

                      Text(
                        "Key Features:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10 * scaleFactor),

                      // ✅ Pass the scale factor to the helper method.
                      _buildFeature(
                        "Precision Control:",
                        "The remote control provides precise and responsive control over the drone’s "
                        "movements. This ensures that every stroke of paint is accurate and meets the "
                        "project’s specifications.",
                        scaleFactor,
                      ),
                      _buildFeature(
                        "Compatibility:",
                        "Designed specifically for use with Colorown Drones, ensuring seamless integration "
                        "and optimal performance.",
                        scaleFactor,
                      ),
                      _buildFeature(
                        "Wireless Connectivity:",
                        "Utilizes advanced wireless technology (e.g., long-range radio or Wi-Fi) to maintain "
                        "a stable connection between the remote control and the drone, even in challenging environments.",
                        scaleFactor,
                      ),
                      _buildFeature(
                        "Intuitive Interface:",
                        "The user-friendly interface on the remote control simplifies navigation and control, "
                        "allowing operators to adjust parameters such as paint flow speed with ease.",
                        scaleFactor,
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

  // ✅ Removed 'static' and added 'scaleFactor' parameter to build responsive feature blocks.
  Widget _buildFeature(String title, String description, double scaleFactor) {
    return Padding(
      // ✅ Responsive bottom padding.
      padding: EdgeInsets.only(bottom: 12 * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              // ✅ Responsive font size with clamping.
              fontSize: (15 * scaleFactor).clamp(13.0, 17.0),
            ),
          ),
          // ✅ Responsive spacing.
          SizedBox(height: 4 * scaleFactor),
          Text(
            description,
            style: TextStyle(
              color: Colors.white70,
              fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}