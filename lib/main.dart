import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '././screens/kiosk-main.dart'; // Your main kiosk screen

// Helper function to play a light haptic tap
void _playHapticFeedback() {
  HapticFeedback.lightImpact(); // subtle tactile response
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to landscape
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide system UI for kiosk mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Optional: haptic tap on startup
  _playHapticFeedback();

  runApp(const WheelchairKioskApp());
}

class WheelchairKioskApp extends StatelessWidget {
  const WheelchairKioskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediHub Demo Kiosk',
      home: const KioskMain(),
      theme: ThemeData(
        useMaterial3: true,

        // 🧩 Apply GT Walsheim Pro font globally
        fontFamily: 'GT Walsheim Pro',

        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,

        // --- Ripple / Highlight feedback ---
        splashColor: Colors.blue.withOpacity(0.4),
        highlightColor: Colors.blue.withOpacity(0.1),
        splashFactory: InkRipple.splashFactory,

        // --- ListTile theme (flat, full-width taps) ---
        listTileTheme: const ListTileThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
