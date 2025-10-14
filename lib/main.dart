import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '././screens/kiosk-main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to landscape for kiosk mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Hide system UI for kiosk mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
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
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}