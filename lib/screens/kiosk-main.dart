// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medihub_tests/screens/admin/admin_dashboard_screen.dart';
import 'catalog/product_catalog_screen.dart';


class KioskMain extends StatefulWidget {
  const KioskMain({super.key});

  @override
  State<KioskMain> createState() => _KioskMainState();
}

class _KioskMainState extends State<KioskMain> {
  // State variable to manage the loading status of the page
  bool _isLoading = false;

  void _navigateToCatalog() async {
    // 1. Set loading state to true to show the full-page overlay
    setState(() {
      _isLoading = true;
    });

    // 2. Simulate data fetching or preparation time (increased for better visibility of the loading screen)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. Navigate to the catalog screen
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductCatalogScreen(),
        ),
      );
    }
    
    // 4. Once navigation completes (e.g., user presses back), reset loading state
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 246, 245, 247),
            ],
          ),
        ),
        // Wrapping the content in a Stack to overlay the loading animation
        child: Stack( 
          children: [
            // --- Main Content Layer (Always visible, but disabled when loading) ---
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // SVG Logo - centered with max width constraint
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 600, // Maximum width
                          maxHeight: 80,  // Reduced height
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: SvgPicture.asset(
                            'assets/images/medihub-logo.svg',
                            width: double.infinity,
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              Colors.deepPurple,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                    const SizedBox(height: 24),
                    ElevatedButton(
                      // Button is disabled when loading
                      onPressed: _isLoading ? null : _navigateToCatalog, 
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                        // Explicitly set colors for better aesthetics
                        foregroundColor: Colors.deepPurple, 
                        backgroundColor: Colors.white,
                      ),
                      // The button child is always the text, as the loading is now full-screen
                      child: const Text('Start Shopping'), 
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminDashboardScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Admin Access',
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Loading Overlay Layer (Conditional Full-Screen) ---
            if (_isLoading)
              Container(
                // This covers the whole screen
                color: Colors.black54, // Semi-transparent gray background
                child: const Center(
                  // We only display the CircularProgressIndicator now
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
