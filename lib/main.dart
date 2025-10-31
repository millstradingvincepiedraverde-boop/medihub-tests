import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './screens/kiosk-main.dart';
import './controllers/product_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/order_service.dart';

void _playHapticFeedback() {
  HapticFeedback.lightImpact(); // subtle tactile response
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // ✅ Create one instance of OrderService
  final orderService = OrderService();

  // ✅ Load saved session data (if any)
  await orderService.loadCustomerFromSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => orderService),
        ChangeNotifierProvider(create: (_) => orderService.customer),
      ],
      child: const WheelchairKioskApp(),
    ),
  );

  // 🔒 Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 🧭 Hide system UI for kiosk-style fullscreen mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Optional haptic tap on startup
  _playHapticFeedback();
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
        fontFamily: 'GT Walsheim Pro',
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
        splashColor: Colors.blue.withOpacity(0.4),
        highlightColor: Colors.blue.withOpacity(0.1),
        splashFactory: InkRipple.splashFactory,
        listTileTheme: const ListTileThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
