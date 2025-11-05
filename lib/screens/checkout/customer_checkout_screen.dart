// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medihub_tests/models/customer.dart';
import 'package:medihub_tests/models/postage_rate.dart';
import 'package:medihub_tests/screens/checkout/order_confirmation_screen.dart';
import 'package:medihub_tests/services/order_service.dart';
import 'package:medihub_tests/services/postage_service.dart';
import 'package:medihub_tests/widgets/checkout/address_suggestions_overlay.dart';
import 'package:medihub_tests/widgets/checkout/checkout_theme.dart';
import 'package:medihub_tests/widgets/checkout/custom_text_field.dart';
import 'package:medihub_tests/widgets/checkout/delivery_options.dart';
import 'package:medihub_tests/widgets/checkout/order_summary.dart';
import 'package:medihub_tests/widgets/checkout/section_title.dart';
import 'package:medihub_tests/widgets/checkout/submit_buttons.dart';

/// Shows the customer info checkout modal
Future<void> showCustomerInfoModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.5),
    isDismissible: true,
    enableDrag: false,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: (context) => const CustomerInfoBottomSheet(),
  );
}

class CustomerInfoBottomSheet extends StatefulWidget {
  const CustomerInfoBottomSheet({super.key});

  @override
  State<CustomerInfoBottomSheet> createState() =>
      _CustomerInfoBottomSheetState();
}

class _CustomerInfoBottomSheetState extends State<CustomerInfoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();
  final _postageService = PostageService();

  // 🧠 Controllers for all inputs
  final _controllers = {
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'address': TextEditingController(),
    'apt': TextEditingController(),
    'postcode': TextEditingController(),
    'city': TextEditingController(),
    'state': TextEditingController(),
  };

  String _deliveryMethod = 'standard';
  List<PostageRate> _postageRates = [];
  bool _isLoadingRates = false;

  // Google Places
  FlutterGooglePlacesSdk? _places;
  List<AutocompletePrediction> _predictions = [];
  bool _isSearching = false;
  final FocusNode _addressFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    final customer = Provider.of<OrderService>(context, listen: false).customer;

    _controllers['email']?.text = customer.email;
    _controllers['phone']?.text = customer.phone;
    _controllers['firstName']?.text = customer.firstName;
    _controllers['lastName']?.text = customer.lastName;
    _controllers['address']?.text = customer.address;
    _controllers['apt']?.text = customer.apartment;
    _controllers['postcode']?.text = customer.postcode.isNotEmpty
        ? customer.postcode
        : '2000'; // ✅ default postcode
    _controllers['city']?.text = customer.city;
    _controllers['state']?.text = customer.state;

    _setupListeners();
    _initializePlaces();

    final initialPostcode = customer.postcode.isNotEmpty
        ? customer.postcode
        : '2000';
    _fetchPostageRates(initialPostcode);
  }

  void _setupListeners() {
    _controllers['address']!.addListener(_onAddressChanged);
    _addressFocusNode.addListener(_onAddressFocusChanged);
  }

  Future<void> _initializePlaces() async {
    try {
      final apiKey =
          dotenv.env['GOOGLE_PLACES_API_KEY'] ??
          dotenv.env['GOOGLE_API_KEY'] ??
          '';
      if (apiKey.isEmpty) return;
      _places = FlutterGooglePlacesSdk(apiKey);
      await _places!.isInitialized();
    } catch (e) {
      debugPrint('❌ Failed to initialize Google Places SDK: $e');
    }
  }

  // 🏠 Address logic
  void _onAddressChanged() {
    final query = _controllers['address']!.text.trim();
    if (query.length >= 3) {
      _searchPlaces(query);
    } else {
      setState(() {
        _predictions = [];
        _removeOverlay();
      });
    }
  }

  void _onAddressFocusChanged() {
    if (!_addressFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 100), _removeOverlay);
    } else if (_predictions.isNotEmpty) {
      _showOverlay();
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 3 || _places == null) {
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
      setState(() {
        _predictions = predictions.predictions;
        _isSearching = false;
      });

      if (_addressFocusNode.hasFocus && _predictions.isNotEmpty)
        _showOverlay();
      else
        _removeOverlay();
    } catch (e) {
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
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: renderBox.size.width + 44,
        left: renderBox.localToGlobal(Offset.zero).dx - 20,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, renderBox.size.height + 30),
          child: AddressSuggestionsOverlay(
            predictions: _predictions,
            isSearching: _isSearching,
            onSelectPlace: (placeId) {
              _selectPlace(placeId);
              _removeOverlay();
              _addressFocusNode.unfocus();
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
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

      if (place.place?.addressComponents == null) return;

      final components = _parseAddressComponents(
        place.place!.addressComponents!,
      );
      final prefix = _extractUnitPrefix(_controllers['address']!.text);

      setState(() {
        _controllers['address']!.text = _buildAddress(
          components,
          prefix,
          place.place?.name,
        );
        _controllers['city']!.text = components['locality'] ?? '';
        _controllers['state']!.text = components['state'] ?? '';
        _controllers['postcode']!.text = components['postcode'] ?? '';
        _predictions = [];
      });

      if (components['postcode']?.isNotEmpty ?? false) {
        _fetchPostageRates(components['postcode']!);
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch place details: $e');
    }
  }

  Map<String, String> _parseAddressComponents(List components) {
    final result = <String, String>{};
    for (final component in components) {
      final types = component.types;
      if (types.contains('street_number'))
        result['streetNumber'] = component.name;
      else if (types.contains('route'))
        result['route'] = component.name;
      else if (types.contains('locality'))
        result['locality'] = component.name;
      else if (types.contains('administrative_area_level_1'))
        result['state'] = component.shortName;
      else if (types.contains('postal_code'))
        result['postcode'] = component.name;
    }
    return result;
  }

  String _extractUnitPrefix(String text) {
    final trimmed = text.trim();
    return trimmed.contains('/') ? '${trimmed.split('/').first.trim()}/' : '';
  }

  String _buildAddress(
    Map<String, String> components,
    String prefix,
    String? placeName,
  ) {
    final route = components['route'] ?? '';
    final streetNumber = components['streetNumber'] ?? '';
    final locality = components['locality'] ?? '';

    if (route.isNotEmpty) {
      return '$prefix${streetNumber.isNotEmpty ? "$streetNumber " : ""}$route'
          .trim();
    } else if (placeName != null) {
      return '$prefix$placeName'.trim();
    } else if (locality.isNotEmpty) {
      return '$prefix$locality'.trim();
    }
    return '';
  }

  // 🚚 Fetch delivery rates
  Future<void> _fetchPostageRates(String postcode) async {
    if (postcode.length < 4) return;
    setState(() {
      _isLoadingRates = true;
      _postageRates.clear();
    });

    try {
      Map<String, PostageRate> onDemandOptions = {};
      double standardTotal = 0.0;
      bool allHaveOnDemand = true;

      for (final item in _orderService.cartItems) {
        try {
          final rates = await _postageService.fetchPostageRates(
            sku: item.product.sku,
            zip: postcode,
            qty: item.quantity,
          );

          if (rates.isEmpty) {
            allHaveOnDemand = false;
            continue;
          }

          final onDemand = rates.where((r) => r.code == 'ON_DEMAND').toList();
          final standard = rates.where((r) => r.code == 'STANDARD').toList();

          if (onDemand.isNotEmpty) {
            for (final rate in onDemand) {
              onDemandOptions[rate.service] = rate;
            }
          } else {
            allHaveOnDemand = false;
          }

          if (standard.isNotEmpty) {
            standardTotal += standard.first.cost;
          }
        } catch (e) {
          allHaveOnDemand = false;
        }
      }

      if (allHaveOnDemand && onDemandOptions.isNotEmpty) {
        _postageRates = onDemandOptions.values.map((rate) {
          return PostageRate(
            service: '${rate.service} - ${rate.eta}',
            eta: 'Delivered free today',
            cost: 0.0,
            code: 'FREE_ON_DEMAND',
            sku: 'ALL',
          );
        }).toList();
      } else {
        _postageRates = [
          PostageRate(
            service: 'Standard Delivery',
            eta: '2–5 Business Days',
            cost: standardTotal,
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

  // 🧾 Submit order
  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      final customer = Provider.of<Customer>(context, listen: false);
      final orderService = Provider.of<OrderService>(context, listen: false);

      // Update current customer data (in memory only)
      customer.update(
        firstName: _controllers['firstName']!.text.trim(),
        lastName: _controllers['lastName']!.text.trim(),
        email: _controllers['email']!.text.trim(),
        phone: _controllers['phone']!.text.trim(),
        address: _controllers['address']!.text.trim(),
        apartment: _controllers['apt']!.text.trim(),
        postcode: _controllers['postcode']!.text.trim(),
        city: _controllers['city']!.text.trim(),
        state: _controllers['state']!.text.trim(),
        deliveryMethod: _deliveryMethod,
      );

      if (!customer.isValid()) {
        final errors = customer.getValidationErrors();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors.values.join('\n')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final order = orderService.placeOrder();
      customer.reset(); // clear memory after order

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(order: order),
        ),
      );
    }
  }

  // 🧹 Cleanup
  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    _addressFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  // 🧱 UI
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 24 : 40,
                  isMobile ? 12 : 20,
                  isMobile ? 16 : 24,
                  isMobile ? 12 : 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontFamily: CheckoutTheme.fontFamily,
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
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 24 : 40),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildFormSection(isMobile),
                            const SizedBox(height: 24),
                            _buildSummarySection(isMobile),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildFormSection(isMobile),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 2,
                              child: _buildSummarySection(isMobile),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧾 Form section
  Widget _buildFormSection(bool isMobile) {
    final orderService = Provider.of<OrderService>(context);
    final customer = orderService.customer;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
                // --- Contact Info ---
                CustomTextField(
                  controller: _controllers['email']!,
                  label: "Email address*",
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? "Email is required" : null,
                  onChanged: (v) => customer.email = v,
                ),
                const SizedBox(height: 18),

                CustomTextField(
                  controller: _controllers['phone']!,
                  label: "Phone number*",
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v!.isEmpty ? "Phone number is required" : null,
                  onChanged: (v) => customer.phone = v,
                ),
                const SizedBox(height: 28),

                // --- Delivery Options ---
                SectionTitle('Delivery Details', isMobile: isMobile),
                const SizedBox(height: 16),

                DeliveryOptions(
                  isLoading: _isLoadingRates,
                  rates: _postageRates,
                  selectedMethod: _deliveryMethod,
                  onMethodChanged: (method) {
                    setState(() => _deliveryMethod = method);
                    customer.deliveryMethod = method;
                  },
                ),
                const SizedBox(height: 28),

                // --- Billing Info ---
                SectionTitle('Billing Details', isMobile: isMobile),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _controllers['firstName']!,
                        label: "First Name*",
                        validator: (v) => v!.isEmpty ? "Required" : null,
                        onChanged: (v) => customer.firstName = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _controllers['lastName']!,
                        label: "Last Name*",
                        validator: (v) => v!.isEmpty ? "Required" : null,
                        onChanged: (v) => customer.lastName = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CompositedTransformTarget(
                  link: _layerLink,
                  child: CustomTextField(
                    controller: _controllers['address']!,
                    label: "Billing address*",
                    focusNode: _addressFocusNode,
                    validator: (v) => v!.isEmpty ? "Address is required" : null,
                    onChanged: (v) => customer.address = v,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _controllers['apt']!,
                        label: "Apartment, suite. (optional)",
                        onChanged: (v) => customer.apartment = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _controllers['postcode']!,
                        label: "Postcode*",
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          customer.postcode = v;
                          _fetchPostageRates(v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _controllers['city']!,
                        label: "City",
                        onChanged: (v) => customer.city = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _controllers['state']!,
                        label: "State",
                        onChanged: (v) => customer.state = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Payment buttons - INSIDE container
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A306D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Pay now on terminal',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _submitOrder,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: Color(0xFF4A306D),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Pay later with NDIS',
                          style: TextStyle(
                            color: Color(0xFF4A306D),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Payment icons - OUTSIDE container, positioned to the right of buttons
        Positioned(
          right: -180,
          bottom: 80,
          child: _buildPaymentIconsRow([
            'assets/icons/visa-icon.svg',
            'assets/icons/mastercard-icon.svg',
            'assets/icons/amex-icon.svg',
            'assets/icons/paypal-icon.svg',
          ]),
        ),
        Positioned(
          right: -60,
          bottom: 16,
          child: _buildPaymentIconsRow(['assets/icons/ndis.svg']),
        ),
      ],
    );
  }

  Widget _buildSummarySection(bool isMobile) {
    return OrderSummary(
      cartItems: _orderService.cartItems,
      subtotal: _orderService.cartTotal,
      rates: _postageRates,
      deliveryMethod: _deliveryMethod,
      isMobile: isMobile,
      onEditCart: () => Navigator.pop(context),
    );
  }

  Widget _buildPaymentIconsRow(List<String> assetPaths) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: assetPaths.map((path) {
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            height: 28,
            width: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SvgPicture.asset(
              path.replaceAll('.png', '.svg'),
              fit: BoxFit.contain,
              placeholderBuilder: (context) => Icon(
                Icons.credit_card,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
