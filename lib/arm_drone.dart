import 'dart:ui';
import 'package:flutter/material.dart';
import 'mavlink_service.dart'; // Import your actual MavlinkService

class ArmDronePage extends StatelessWidget {
  final String serverUrl;
  final MavlinkService mavlinkService; 

  const ArmDronePage({
    super.key,
    required this.serverUrl,
    required this.mavlinkService,
  });

  @override
  Widget build(BuildContext context) {
    // This is typically a full-screen view for the drone's video feed.
    return Scaffold(
      body: Stack(
        children: [
          // =================================================
          // == LAYER 1: BACKGROUND / VIDEO FEED
          // =================================================
          Positioned.fill(
            child: Container(
              // Using the provided asset path for the background image
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/rc_background.png'),
                  fit: BoxFit.cover,
                  // Removed onError as it prevents const constructor usage if left as a lambda
                ),
              ),
              // In a real app, this is where the Camera Feed Widget would go
              // For now, it just shows the background image.
            ),
          ),

          // =================================================
          // == LAYER 2: OVERLAY UI ELEMENTS
          // =================================================

          // 1. TOP STATUS BAR (Time, Status, Battery)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopStatusBar(),
          ),

          // 2. COMPASS / NAVIGATION INDICATOR (Top Right)
          const Positioned(
            top: 20,
            right: 20,
            child: CompassIndicator(),
          ),

          // 3. CENTER ARM/DISARM BUTTON AND TAKE OFF SLIDER WRAPPER
          Align(
            alignment: const Alignment(0, 0.7), // Aligned slightly below center
            child: ArmTakeOffWrapper(
              mavlinkService: mavlinkService,
            ),
          ),

          // 4. BOTTOM CONTROL BAR (Manual/Auto & Utility Buttons)
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomControlBar(),
          ),
        ],
      ),
    );
  }
}

// =================================================
// == TOP STATUS BAR (unchanged)
// =================================================
class TopStatusBar extends StatelessWidget {
  const TopStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.black.withOpacity(0.3), // Light black overlay for contrast
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Left Side (Time & Date) ---
          const Text(
            '9:41 Mon Jun 22',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),

          // --- Center (UAV Status) ---
          Row(
            children: [
              const Icon(Icons.flight_outlined, size: 18, color: Colors.green),
              const SizedBox(width: 4),
              const Text(
                'UAV',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              Text(
                '100%',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade400),
              ),
            ],
          ),

          // --- Right Side (Connectivity & Battery) ---
          const Row(
            children: [
              Icon(Icons.wifi, size: 20, color: Colors.white),
              SizedBox(width: 8),
              // Assuming this icon represents remote control or signal strength
              Icon(Icons.signal_cellular_4_bar,
                  size: 20, color: Colors.white), 
              SizedBox(width: 8),
              Text(
                '100%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 20, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

// =================================================
// == COMPASS INDICATOR (unchanged)
// =================================================

class CompassIndicator extends StatelessWidget {
  const CompassIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'N', // North direction indicator
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================
// == ARM/DISARM AND TAKE OFF WRAPPER
// This widget manages the state of the central control area.
// =================================================
class ArmTakeOffWrapper extends StatefulWidget {
  final MavlinkService mavlinkService;

  const ArmTakeOffWrapper({
    super.key,
    required this.mavlinkService,
  });

  @override
  State<ArmTakeOffWrapper> createState() => _ArmTakeOffWrapperState();
}

enum ArmState { armed, disarmed, arming, disarming, airborne }

class _ArmTakeOffWrapperState extends State<ArmTakeOffWrapper> {
  ArmState _state = ArmState.disarmed;

  // This function wraps the service call for ARM/DISARM.
  Future<bool> _callArmDisarmService(bool arm) async {
    final endpoint = arm ? 'arm' : 'disarm';
    try {
      await widget.mavlinkService.sendCommand(endpoint);
      return true;
    } catch (e) {
      print('MAVLink call to $endpoint failed: $e');
      return false;
    }
  }
  
  // This function calls the TAKEOFF command.
  Future<bool> _callTakeOffService() async {
    const endpoint = 'takeoff';
    try {
      // Assuming 'takeoff' command may require altitude (e.g., 5 meters)
      await widget.mavlinkService.sendCommand(endpoint, body: {'altitude': 5.0});
      return true;
    } catch (e) {
      print('MAVLink call to $endpoint failed: $e');
      return false;
    }
  }

  void _handleArmDisarmPress() async {
    if (_state == ArmState.arming || _state == ArmState.disarming) return;

    final isCurrentlyDisarmed = _state == ArmState.disarmed;
    final targetState = isCurrentlyDisarmed ? ArmState.arming : ArmState.disarming;

    setState(() => _state = targetState);

    final success = await _callArmDisarmService(isCurrentlyDisarmed);

    if (mounted) {
      setState(() {
        if (success) {
          _state = isCurrentlyDisarmed ? ArmState.armed : ArmState.disarmed;
        } else {
          _state = isCurrentlyDisarmed ? ArmState.disarmed : ArmState.armed;
        }
      });
    }
  }

  void _handleTakeOffComplete() async {
    if (_state != ArmState.armed) return; // Only take off if armed

    setState(() => _state = ArmState.arming); // Use arming state temporarily for takeoff loading
    
    final success = await _callTakeOffService();

    if (mounted) {
      setState(() {
        if (success) {
          _state = ArmState.airborne; // New state after successful takeoff
          print('Drone is now: Airborne');
        } else {
          _state = ArmState.armed; // Revert to armed state if takeoff fails
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArmed = _state == ArmState.armed;
    final isDisarmed = _state == ArmState.disarmed;
    final isLoading = _state == ArmState.arming || _state == ArmState.disarming;
    
    // Renders the main central control area
    Widget centralControl;

    if (isLoading) {
      // Show loading indicator above the button
      centralControl = ArmControlButton(
        state: _state,
        onPressed: _handleArmDisarmPress,
        isEnabled: false, // Button disabled during loading
      );
    } else if (isArmed) {
      // Show the DisARM button and the Take Off slider side-by-side
      centralControl = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 1. DISARM BUTTON
          ArmControlButton(
            state: _state,
            onPressed: _handleArmDisarmPress,
            isEnabled: true,
          ),
          const SizedBox(width: 40),
          // 2. TAKE OFF SLIDER
          TakeOffSlider(
            onTakeOff: _handleTakeOffComplete,
          ),
        ],
      );
    } else if (isDisarmed) {
      // Show the ARM button only
      centralControl = ArmControlButton(
        state: _state,
        onPressed: _handleArmDisarmPress,
        isEnabled: true,
      );
    } else {
      // For Airborne or other future states, show DISARM button for safety
       centralControl = ArmControlButton(
        state: _state,
        onPressed: _handleArmDisarmPress,
        isEnabled: true,
      );
    }

    return centralControl;
  }
}

// =================================================
// == ARM/DISARM BUTTON (now stateless, driven by wrapper state)
// =================================================
class ArmControlButton extends StatelessWidget {
  final ArmState state;
  final VoidCallback onPressed;
  final bool isEnabled;

  const ArmControlButton({
    super.key,
    required this.state,
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final isArmed = state == ArmState.armed || state == ArmState.airborne;
    final isLoading = state == ArmState.arming || state == ArmState.disarming;
    
    final text = isArmed ? 'DISARM' : 'ARM';
    final processText = state == ArmState.arming ? 'arming..' : 'disarming..';
    
    final color = isArmed ? Colors.red.shade700 : Colors.teal.shade500;
    
    // Determine the button's final enabled state
    final buttonEnabled = isEnabled && !isLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ARMING/DISARMING INDICATOR
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              processText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)
                ],
              ),
            ),
          ),
        
        // ARM/DISARM BUTTON
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: OutlinedButton.icon(
              onPressed: buttonEnabled ? onPressed : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: buttonEnabled
                    ? color.withOpacity(0.7)
                    : Colors.grey.withOpacity(0.5),
                foregroundColor: Colors.white,
                side: BorderSide(
                    color: buttonEnabled
                        ? color.withOpacity(0.9)
                        : Colors.grey.withOpacity(0.5),
                    width: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
              ),
              icon: const Icon(Icons.link, size: 20),
              label: Text(
                isLoading ? '...' : text,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        // Placeholder text when armed but not taking off
        if (isArmed && !isLoading)
           const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Armed',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
            ),
          )
      ],
    );
  }
}

// =================================================
// == NEW TAKE OFF SLIDER WIDGET
// =================================================
class TakeOffSlider extends StatefulWidget {
  final VoidCallback onTakeOff;
  
  const TakeOffSlider({
    super.key,
    required this.onTakeOff,
  });

  @override
  State<TakeOffSlider> createState() => _TakeOffSliderState();
}

class _TakeOffSliderState extends State<TakeOffSlider> {
  double _dragY = 0.0;
  final double _minHeight = 0.0;
  final double _maxHeight = 100.0; // Total drag distance
  final double _triggerHeight = 80.0; // Drag this far to trigger takeoff

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Decrement _dragY to simulate dragging upwards (Y-axis is inverted)
      _dragY -= details.delta.dy;
      // Clamp the value between min and max
      _dragY = _dragY.clamp(_minHeight, _maxHeight);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragY >= _triggerHeight) {
      // Takeoff successful: Reset and call the external handler
      _dragY = 0.0;
      widget.onTakeOff();
    } else {
      // Drag failed: Snap back to the bottom
      setState(() {
        _dragY = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: Column(
        children: [
          const Text(
            'Take Off',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 3),
              ]
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: _maxHeight + 20, // Slider track height + padding for the handle
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Inner vertical track for visual feedback
                Container(
                  width: 10,
                  height: _maxHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),

                // Drag handle (the blue circle)
                Positioned(
                  bottom: _dragY,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade900.withOpacity(0.7),
                          blurRadius: 10,
                        )
                      ]
                    ),
                    child: const Center(
                      child: Icon(Icons.flight_takeoff, color: Colors.white, size: 16)
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================
// == BOTTOM CONTROL BAR (unchanged)
// =================================================
class BottomControlBar extends StatefulWidget {
  const BottomControlBar({super.key});

  @override
  State<BottomControlBar> createState() => _BottomControlBarState();
}

class _BottomControlBarState extends State<BottomControlBar> {
  bool isAutoMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.black.withOpacity(0.3), // Overlay for contrast
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Left Side (Manual/Auto Toggle) ---
          Row(
            children: [
              Text(
                'Manual',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isAutoMode ? Colors.white54 : Colors.white,
                ),
              ),
              Switch(
                value: isAutoMode,
                onChanged: (value) {
                  setState(() {
                    isAutoMode = value;
                  });
                },
                activeColor: Colors.blue.shade600,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white54,
              ),
              Text(
                'Auto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isAutoMode ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),

          // --- Center (Arrow/Indicator) ---
          const Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.white),

          // --- Right Side (Utility Buttons) ---
          Row(
            children: [
              // Fullscreen Toggle
              IconButton(
                icon: const Icon(Icons.fullscreen, size: 28),
                color: Colors.white,
                onPressed: () {
                  print('Toggle Fullscreen');
                },
              ),
              const SizedBox(width: 16),
              // Camera/Photo Button
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, size: 28),
                color: Colors.white,
                onPressed: () {
                  print('Take Photo/Video');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
