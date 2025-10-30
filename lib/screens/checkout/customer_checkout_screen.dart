import 'package:flutter/material.dart';
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
  // === Services / controllers ===
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();
  final _postageController = PostageController();

  // === Text controllers ===
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _aptController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  // === UI state ===
  String _deliveryMethod = 'standard';
  List<PostageRate> _postageRates = [];
  bool _isLoadingRates = false;

  // === animations for bottom sheet ===
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // === Google Places ===
  FlutterGooglePlacesSdk? _places;
  List<AutocompletePrediction> _predictions = [];
  bool _isSearching = false;
  final FocusNode _addressFocusNode = FocusNode();

  // overlay positioning
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // styling
  static const Color _primaryColor = Color(0xFF4A306D);
  static const String _fontFamily = 'Poppins';

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

    // Listen to typing and show suggestions
    _addressController.addListener(() {
      final q = _addressController.text.trim();
      if (q.length >= 3) {
        _searchPlaces(q);
      } else {
        _predictions = [];
        _removeOverlay();
        setState(() {});
      }
    });

    // Dismiss overlay when address field loses focus
    _addressFocusNode.addListener(() {
      if (!_addressFocusNode.hasFocus) {
        // small delay so a tap on a suggestion still works
        Future.delayed(const Duration(milliseconds: 100), () {
          _removeOverlay();
        });
      } else {
        // if we have predictions show them
        if (_predictions.isNotEmpty) _showOverlay();
      }
    });

    _initializePlaces();
  }

  void _initializePlaces() async {
    try {
      // accept either env key name to be flexible
      final apiKey =
          dotenv.env['GOOGLE_PLACES_API_KEY'] ??
          dotenv.env['GOOGLE_API_KEY'] ??
          '';
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
    _removeOverlay();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3 || _places == null) {
      // ensure overlay removed
      _removeOverlay();
      setState(() {
        _isSearching = false;
        _predictions = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final predictions = await _places!.findAutocompletePredictions(
        query,
        countries: ['AU'],
      );

      debugPrint('Predictions count: ${predictions.predictions.length}');
      for (final p in predictions.predictions) {
        debugPrint('➡️ ${p.fullText}');
      }

      _predictions = predictions.predictions;
      setState(() => _isSearching = false);

      if (_addressFocusNode.hasFocus && _predictions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } catch (e) {
      debugPrint('❌ Places API error: $e');
      setState(() {
        _isSearching = false;
        _predictions = [];
      });
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    if (_predictions.isEmpty) return;

    final renderBox =
        _addressFocusNode.context!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width + 44,
          left: offset.dx - 20,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 30), // small gap below TextField
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 350),
                decoration: BoxDecoration(
                  color: Colors.white,

                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🧭 Header “SUGGESTIONS”
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'SUGGESTIONS',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // 🔍 List of suggestions
                    Expanded(
                      child: _isSearching
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              itemCount: _predictions.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) {
                                final p = _predictions[index];
                                return InkWell(
                                  onTap: () {
                                    _selectPlace(p.placeId);
                                    _removeOverlay();
                                    _addressFocusNode.unfocus();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.primaryText,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                p.secondaryText,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // 🪄 “Powered by Google”
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      alignment: Alignment.centerRight,
                      child: Image.network(
                        'https://developers.google.com/maps/documentation/images/powered_by_google_on_white.png',
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlay);
    _overlayEntry = overlay;
  }

  void _removeOverlay() {
    try {
      _overlayEntry?.remove();
    } catch (_) {}
    _overlayEntry = null;
  }

  Future<void> _selectPlace(String placeId) async {
    if (_places == null || placeId.isEmpty) return;

    try {
      final place = await _places!.fetchPlace(
        placeId,
        fields: [
          PlaceField.Address,
          PlaceField.AddressComponents,
          PlaceField.Name,
        ],
      );

      if (place.place?.addressComponents != null) {
        String streetNumber = '';
        String route = '';
        String locality = '';
        String state = '';
        String postcode = '';
        String address = '';

        // 🧩 Keep user's typed unit number (e.g., "12/") if it exists
        final currentText = _addressController.text.trim();
        String prefix = '';
        if (currentText.contains('/')) {
          prefix = currentText.split('/').first.trim() + '/';
        }

        for (final component in place.place!.addressComponents!) {
          final types = component.types;

          if (types.contains('street_number')) {
            streetNumber = component.name;
          } else if (types.contains('route')) {
            route = component.name;
          } else if (types.contains('locality')) {
            locality = component.name;
          } else if (types.contains('administrative_area_level_1')) {
            state = component.shortName;
          } else if (types.contains('postal_code')) {
            postcode = component.name;
          }
        }

        // 🏠 If route is found, it's a street address — keep prefix (unit number)
        if (route.isNotEmpty) {
          address =
              '${prefix}${streetNumber.isNotEmpty ? "$streetNumber " : ""}$route';
        }
        // 🧭 Otherwise, use the place name (like “Sydney Airport”)
        else if (place.place?.name != null) {
          address = '${prefix}${place.place!.name!}';
        }
        // 🏙️ Fallback to locality (e.g., “Mascot”) if all else fails
        else if (locality.isNotEmpty) {
          address = '${prefix}${locality}';
        }

        setState(() {
          _addressController.text = address.trim();
          _cityController.text = locality;
          _stateController.text = state;
          _postcodeController.text = postcode;
          _predictions = [];
        });

        if (postcode.isNotEmpty) {
          _fetchPostageRates(postcode);
        }
      } else {
        debugPrint('⚠️ Place has no address components');
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

    setState(() {
      _isLoadingRates = true;
      _postageRates.clear();
    });

    try {
      List<PostageRate> allRates = [];
      bool allHaveOnDemand = true;

      // 🧮 Fetch rates for each cart item
      for (final item in _orderService.cartItems) {
        final sku = item.product.sku;
        final qty = item.quantity;

        try {
          final rates = await _postageController.fetchRates(sku, postcode, qty);
          if (rates.isNotEmpty) {
            allRates.addAll(rates);

            if (!rates.any((r) => r.code == 'ON_DEMAND')) {
              allHaveOnDemand = false;
            }
          } else {
            allHaveOnDemand = false;
          }
        } catch (e) {
          debugPrint('⚠️ Error fetching rates for $sku: $e');
          allHaveOnDemand = false;
        }
      }

      if (allHaveOnDemand && allRates.isNotEmpty) {
        // ✅ Show all unique On Demand options (as free)
        final unique = allRates
            .where((r) => r.code == 'ON_DEMAND')
            .map((r) => r.service)
            .toSet();

        _postageRates = allRates
            .where((r) => unique.contains(r.service))
            .map(
              (r) => PostageRate(
                service: r.eta,
                eta: 'Delivered free today',
                cost: 0.0,
                code: 'FREE_ON_DEMAND',
                sku: 'ALL',
              ),
            )
            .toList();
      } else {
        // 🚚 Combine all standard postage costs
        double totalCost = 0.0;
        for (final rate in allRates.where((r) => r.code != 'ON_DEMAND')) {
          totalCost += rate.cost;
        }

        _postageRates = [
          PostageRate(
            service: 'Standard Delivery',
            eta: '2–5 Business Days',
            cost: totalCost,
            code: 'STANDARD',
            sku: 'ALL',
          ),
        ];
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch postage rates: $e');
    } finally {
      setState(() => _isLoadingRates = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        color: Colors.black54,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        borderSide: const BorderSide(color: _primaryColor, width: 3),
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
          // dark overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () {
                _removeOverlay();
                Navigator.pop(context);
              },
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          // bottom sheet
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
                    // drag handle
                    Container(
                      width: 50,
                      height: 5,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // header
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 24 : 40,
                        isMobile ? 12 : 20,
                        isMobile ? 16 : 24,
                        isMobile ? 12 : 20,
                      ),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Checkout',
                            style: TextStyle(
                              fontFamily: _fontFamily,
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
                    // main content
                    Expanded(
                      child: Container(
                        color: Colors.white,
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
              style: const TextStyle(fontFamily: _fontFamily, fontSize: 16),
              validator: (v) => v!.isEmpty ? "Email is required" : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration("Phone number*"),
              style: const TextStyle(fontFamily: _fontFamily, fontSize: 16),
              validator: (v) => v!.isEmpty ? "Phone number is required" : null,
            ),
            const SizedBox(height: 28),

            // Delivery details header
            Text(
              'Delivery Details',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 16),
            // delivery options (kept visually consistent)
            _buildDeliveryOptions(),
            const SizedBox(height: 28),

            // Billing Details header
            Text(
              'Billing Details',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: isMobile ? 22 : 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF191919),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: _inputDecoration("First Name*"),
                    style: const TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16,
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: _inputDecoration("Last Name*"),
                    style: const TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16,
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Address field with CompositedTransformTarget so overlay positions correctly
            CompositedTransformTarget(
              link: _layerLink,
              child: Stack(
                children: [
                  TextFormField(
                    controller: _addressController,
                    focusNode: _addressFocusNode,
                    decoration: _inputDecoration("Billing address*"),
                    style: const TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16,
                    ),
                    validator: (v) => v!.isEmpty ? "Address is required" : null,
                    keyboardType: TextInputType.streetAddress,
                    readOnly: false,
                    autofocus: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
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
                      fontFamily: _fontFamily,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _postcodeController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Postcode*"),
                    style: const TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16,
                    ),
                    onChanged: (v) => _fetchPostageRates(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: _inputDecoration("City"),
                    style: const TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: _inputDecoration("State"),
                    style: const TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons (kept visually identical)
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Pay now on terminal',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: OutlinedButton(
                onPressed: _submitOrder,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Pay later with NDIS',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 16,
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12),
                    // small badge
                    SizedBox(
                      width: 36,
                      height: 22,
                      child: Center(
                        child: Text(
                          'ndis',
                          style: TextStyle(color: Colors.white, fontSize: 12),
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
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_postageRates.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Enter your postcode to view delivery options.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      children: _postageRates.map((rate) {
        final isSelected = _deliveryMethod == rate.service.toLowerCase();

        // 🪄 Split the label
        final parts = rate.service.split(' - ');
        final title = parts.isNotEmpty ? parts.first.trim() : rate.service;
        final subtitle = parts.length > 1 ? parts.last.trim() : '';

        // 🏷️ Handle cost text
        final displayCost =
            (rate.service.toLowerCase().contains('on demand') &&
                rate.cost == 4.95)
            ? 0.0
            : rate.cost;
        final costText = displayCost == 0.0
            ? 'FREE'
            : '\$${displayCost.toStringAsFixed(2)}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () =>
                setState(() => _deliveryMethod = rate.service.toLowerCase()),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? _primaryColor.withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? _primaryColor : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🔘 Radio button on the LEFT
                  Radio<String>(
                    value: rate.service.toLowerCase(),
                    groupValue: _deliveryMethod,
                    onChanged: (val) => setState(
                      () => _deliveryMethod = val ?? _deliveryMethod,
                    ),
                    activeColor: _primaryColor,
                  ),
                  const SizedBox(width: 8),

                  // 📦 Text + FREE on the right
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Texts
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),

                        // 💰 Cost text on the far right
                        Text(
                          costText,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: displayCost == 0.0
                                ? Colors.green.shade700
                                : const Color(0xFF191919),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummarySection(
    List cartItems,
    double total,
    bool isMobile,
    List<PostageRate> rates,
    String deliveryMethod,
  ) {
    final selectedRate = rates.firstWhere(
      (r) => r.service.toLowerCase() == deliveryMethod,
      orElse: () => PostageRate(
        service: 'Standard',
        eta: '',
        cost: 0.0,
        code: '',
        sku: '',
      ),
    );
    final grandTotal = total + selectedRate.cost;

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
                  fontFamily: _fontFamily,
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Edit Cart',
                  style: TextStyle(color: _primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.product.name ?? 'Product',
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${item.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('\$${total.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping'),
              Text(
                selectedRate.cost == 0
                    ? 'FREE'
                    : '\$${selectedRate.cost.toStringAsFixed(2)}',
                style: TextStyle(
                  color: selectedRate.cost == 0
                      ? _primaryColor
                      : const Color(0xFF191919),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${grandTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
