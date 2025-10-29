// 1. Add to pubspec.yaml:
// dependencies:
//   flutter_google_places_sdk: ^1.0.0
//   flutter_dotenv: ^5.1.0

// 2. Create .env file in project root:
// GOOGLE_PLACES_API_KEY=your_api_key_here

// 3. Add to pubspec.yaml assets:
// assets:
//   - .env

// 4. Load in main.dart before runApp:
// await dotenv.load(fileName: ".env");

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/customer.dart';
import '../../services/order_service.dart';
import 'order_confirmation_screen.dart';
import '../../controllers/postage_controller.dart';
import '../../models/postage_rate.dart';

class CustomerInfoScreen extends StatefulWidget {
  const CustomerInfoScreen({super.key});

  @override
  State<CustomerInfoScreen> createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();
  final _postageController = PostageController();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _aptController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String _deliveryMethod = 'standard';
  List<PostageRate> _postageRates = [];
  bool _isLoadingRates = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Google Places
  FlutterGooglePlacesSdk? _places;
  List<AutocompletePrediction> _predictions = [];
  bool _isSearching = false;
  final FocusNode _addressFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween(
      begin: 0.0,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    // Initialize Google Places
    _initializePlaces();
  }

  void _initializePlaces() async {
    try {
      final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        debugPrint('⚠️ Google Places API key not found in .env file');
        return;
      }
      _places = FlutterGooglePlacesSdk(apiKey);
      await _places!.isInitialized();
      debugPrint('✅ Google Places SDK initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Google Places SDK: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _aptController.dispose();
    _postcodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3 || _places == null) {
      setState(() => _predictions = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final predictions = await _places!.findAutocompletePredictions(
        query,
        countries: ['AU'], // Restrict to Australia
      );

      setState(() {
        _predictions = predictions.predictions;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('❌ Places API error: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _selectPlace(String placeId) async {
    if (_places == null) return;

    try {
      final place = await _places!.fetchPlace(
        placeId,
        fields: [PlaceField.Address, PlaceField.AddressComponents],
      );

      if (place.place?.addressComponents != null) {
        String streetNumber = '';
        String route = '';
        String locality = '';
        String state = '';
        String postcode = '';

        for (final component in place.place!.addressComponents!) {
          final types = component.types;

          if (types.contains('street_number')) {
            streetNumber = component.name;
          } else if (types.contains('route')) {
            route = component.name;
          } else if (types.contains('locality')) {
            locality = component.name;
          } else if (types.contains('administrative_area_level_1')) {
            state = component.shortName ?? component.name;
          } else if (types.contains('postal_code')) {
            postcode = component.name;
          }
        }

        setState(() {
          _addressController.text = '$streetNumber $route'.trim();
          _cityController.text = locality;
          _stateController.text = state;
          _postcodeController.text = postcode;
          _predictions = [];
        });

        // Fetch postage rates with the new postcode
        if (postcode.isNotEmpty) {
          _fetchPostageRates(postcode);
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch place details: $e');
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        name:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        notes: null,
      );

      final order = _orderService.placeOrder(
        customerName: customer.name,
        customerEmail: customer.email,
        customerPhone: customer.phone,
        deliveryAddress: customer.address,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(order: order),
        ),
      );
    }
  }

  Future<void> _fetchPostageRates(String postcode) async {
    if (postcode.length < 4) return;
    setState(() => _isLoadingRates = true);
    _postageRates.clear();

    try {
      List<PostageRate> allRates = [];

      for (final item in _orderService.cartItems) {
        final sku = item.product.sku;
        final qty = item.quantity;
        final rates = await _postageController.fetchRates(sku, postcode, qty);
        if (rates.isNotEmpty) {
          allRates.addAll(rates);
        }
      }

      // Check if any item has "On Demand" free shipping
      bool hasFreeShipping = allRates.any(
        (rate) =>
            rate.service.toLowerCase().contains('on demand') &&
            rate.cost == 4.95,
      );

      if (hasFreeShipping) {
        // If any item has free shipping, entire order ships free
        _postageRates = [
          PostageRate(
            service: 'On Demand',
            eta: 'Free shipping applied',
            cost: 0.0,
            code: 'FREE',
            sku: 'combined',
          ),
        ];
      } else {
        // Group rates by service type and sum costs
        Map<String, PostageRate> groupedRates = {};

        for (final rate in allRates) {
          final serviceKey = rate.service.toLowerCase();

          if (groupedRates.containsKey(serviceKey)) {
            // Add to existing service cost
            groupedRates[serviceKey] = PostageRate(
              service: rate.service,
              eta: rate.eta,
              cost: groupedRates[serviceKey]!.cost + rate.cost,
              code: rate.code,
              sku: 'combined',
            );
          } else {
            // First occurrence of this service
            groupedRates[serviceKey] = rate;
          }
        }

        _postageRates = groupedRates.values.toList();
        _postageRates.sort((a, b) => a.cost.compareTo(b.cost));
      }

      setState(() => _isLoadingRates = false);
    } catch (e) {
      debugPrint('❌ Failed to fetch postage rates: $e');
      setState(() => _isLoadingRates = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4A306D), width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final cartItems = _orderService.cartItems;
    final total = _orderService.cartTotal;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          // Bottom sheet sliding up
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: size.height * 0.85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 30,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // Header
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 24 : 40,
                        isMobile ? 12 : 20,
                        isMobile ? 16 : 24,
                        isMobile ? 12 : 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: isMobile ? 28 : 36,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF191919),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: isMobile ? 28 : 32,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F7),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 24 : 40),
                            child: isMobile
                                ? Column(
                                    children: [
                                      _buildFormSection(isMobile),
                                      const SizedBox(height: 24),
                                      _buildSummarySection(
                                        cartItems,
                                        total,
                                        isMobile,
                                        _postageRates,
                                        _deliveryMethod,
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: _buildFormSection(isMobile),
                                      ),
                                      const SizedBox(width: 32),
                                      Expanded(
                                        flex: 2,
                                        child: _buildSummarySection(
                                          cartItems,
                                          total,
                                          isMobile,
                                          _postageRates,
                                          _deliveryMethod,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email & Phone
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration("Email address*"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              validator: (v) => v!.isEmpty ? "Email is required" : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration("Phone number*"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              validator: (v) => v!.isEmpty ? "Phone number is required" : null,
            ),

            const SizedBox(height: 48),

            // Delivery Details Section
            Text(
              'Delivery Details',
              style: TextStyle(
                fontSize: isMobile ? 26 : 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Options
            _buildDeliveryOptions(),

            const SizedBox(height: 48),

            // Billing Details Section
            Text(
              'Billing Details',
              style: TextStyle(
                fontSize: isMobile ? 26 : 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: _inputDecoration("First Name*"),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: _inputDecoration("Last Name*"),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Address field with autocomplete
            Stack(
              children: [
                TextFormField(
                  controller: _addressController,
                  focusNode: _addressFocusNode,
                  decoration: _inputDecoration("Billing address*"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  validator: (v) => v!.isEmpty ? "Address is required" : null,
                  onChanged: _searchPlaces,
                ),
                if (_predictions.isNotEmpty)
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _predictions.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (context, index) {
                            final prediction = _predictions[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Color(0xFF4A306D),
                              ),
                              title: Text(
                                prediction.primaryText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                prediction.secondaryText ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              onTap: () {
                                _selectPlace(prediction.placeId);
                                _addressFocusNode.unfocus();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _aptController,
                    decoration: _inputDecoration(
                      "Apartment, suite. (optional)",
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _postcodeController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Postcode*"),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: _fetchPostageRates,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: _inputDecoration("City"),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: _inputDecoration("State"),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Payment Buttons
            SizedBox(
              width: double.infinity,
              height: 72,
              child: ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A306D),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pay now on terminal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SvgPicture.asset(
                      'assets/icons/paypal.svg',
                      height: 28,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      'assets/icons/mastercard.svg',
                      height: 28,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      'assets/icons/amex.svg',
                      height: 28,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 72,
              child: OutlinedButton(
                onPressed: _submitOrder,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4A306D), width: 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pay later with NDIS',
                      style: TextStyle(
                        color: Color(0xFF4A306D),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A306D),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ndis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    if (_isLoadingRates) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: Color(0xFF4A306D)),
        ),
      );
    }

    if (_postageRates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Enter your postcode to view delivery options.',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF666666),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      children: _postageRates.map((rate) {
        double displayCost = rate.cost;
        String displayLabel;

        if (rate.service.toLowerCase().contains('on demand') &&
            (rate.cost == 4.95)) {
          displayCost = 0.0;
        }

        displayLabel = displayCost == 0.0
            ? 'FREE'
            : '\$${displayCost.toStringAsFixed(2)}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildDeliveryOption(
            rate.service,
            Icons.local_shipping_outlined,
            rate.service.toLowerCase(),
            displayLabel,
            eta: rate.eta,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeliveryOption(
    String title,
    IconData icon,
    String value,
    String price, {
    String? eta,
  }) {
    final isSelected = _deliveryMethod.toLowerCase() == value.toLowerCase();
    return GestureDetector(
      onTap: () => setState(() => _deliveryMethod = value),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3EFFF) : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A306D) : Colors.transparent,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A306D)
                      : const Color(0xFFCCCCCC),
                  width: 3,
                ),
                color: isSelected
                    ? const Color(0xFF4A306D)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.circle, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 20),
            Icon(icon, color: const Color(0xFF191919), size: 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: const Color(0xFF191919),
                    ),
                  ),
                  if (eta != null && eta.isNotEmpty)
                    Text(
                      eta,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: price == 'FREE'
                    ? const Color(0xFF4A306D)
                    : const Color(0xFF191919),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    List cartItems,
    double total,
    bool isMobile,
    List<PostageRate> postageRates,
    String selectedDeliveryMethod,
  ) {
    final selectedRate = postageRates.firstWhere(
      (r) => r.service.toLowerCase() == selectedDeliveryMethod.toLowerCase(),
      orElse: () => PostageRate(
        service: 'Standard',
        eta: '',
        cost: 0.0,
        code: '',
        sku: '',
      ),
    );

    final shippingCost = selectedRate.cost;
    final grandTotal = total + shippingCost;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191919),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Edit Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A306D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cart items
          ...cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} - ${item.quantity}x',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF191919),
                      ),
                    ),
                  ),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF191919),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 32, thickness: 1),

          // Subtotal
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 18, color: Color(0xFF666666)),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191919),
                  ),
                ),
              ],
            ),
          ),

          // Shipping
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shipping',
                style: TextStyle(fontSize: 18, color: Color(0xFF666666)),
              ),
              Text(
                shippingCost == 0
                    ? 'FREE'
                    : '\$${shippingCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: shippingCost == 0
                      ? const Color(0xFF4A306D)
                      : const Color(0xFF191919),
                ),
              ),
            ],
          ),

          const Divider(height: 32, thickness: 1),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191919),
                ),
              ),
              Text(
                '\$${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191919),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
