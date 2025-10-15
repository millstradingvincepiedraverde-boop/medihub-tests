import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '././screens/kiosk-main.dart'; // Assuming this points to your main Kiosk screen

// Helper function to play a light haptic tap
void _playHapticFeedback() {
  // Use HapticFeedback.lightImpact for a satisfying, non-distracting tap feel.
  HapticFeedback.lightImpact();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to landscape for kiosk mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Hide system UI for kiosk mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Play a haptic tap on app start to confirm initialization (optional but cool)
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
        // Set a base color scheme
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,

        // --- GLOBAL RESPONSIVENESS SETTINGS ---

        // 1. VISUAL FEEDBACK (Splash/Ripple Effect)
        // Customize the splash color to make the ripple highly visible
        splashColor: Colors.blue.withOpacity(0.4), 
        // Set a slight highlight color that appears immediately under the touch
        highlightColor: Colors.blue.withOpacity(0.1), 
        // Ensure a clear, circular ripple effect for all standard widgets
        splashFactory: InkRipple.splashFactory,
        
        // 2. Tappable area customization (for ListTile, etc.)
        listTileTheme: const ListTileThemeData(
          // Makes the highlight/splash extend to the full tile width
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
