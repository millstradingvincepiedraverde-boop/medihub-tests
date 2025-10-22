import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/customer.dart';
import '../../services/order_service.dart';
import 'order_confirmation_screen.dart';
import '../../controllers/postage_controller.dart';
import '../../models/postage_rate.dart';
import '../../services/postage_service.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween(
      begin: 0.0,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
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
    super.dispose();
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

  void _closeModal() async {
    await _controller.reverse();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _fetchPostageRates(String postcode) async {
    if (postcode.length < 4) return;
    setState(() => _isLoadingRates = true);

    try {
      final sku = _orderService.cartItems.first.product.sku;
      final qty = _orderService.cartItems.first.quantity;

      final rates = await _postageController.fetchRates(sku, postcode, qty);

      setState(() {
        _postageRates = rates;
        _isLoadingRates = false;
        if (rates.isNotEmpty) {
          _deliveryMethod = rates.first.service.toLowerCase();
        }
      });
    } catch (e) {
      setState(() => _isLoadingRates = false);
    }
  }

  Widget _deliveryOption({
    required String label,
    required String subtitle,
    required String value,
    required String price,
    required FontWeight fontWeight,
  }) {
    final isSelected = _deliveryMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _deliveryMethod = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? const Color(0xFFE9D5F5) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF7B50C7) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF7B50C7) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7B50C7), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = _orderService.cartItems;
    final total = _orderService.cartTotal;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _closeModal,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.85,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Checkout",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            IconButton(
                              onPressed: _closeModal,
                              icon: const Icon(Icons.close, size: 28),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side - Form
                            Expanded(
                              flex: 3,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Your Details",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _firstNameController,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                              decoration: _inputDecoration(
                                                "First Name",
                                              ),
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                  ? "Required"
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _lastNameController,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                              decoration: _inputDecoration(
                                                "Last Name",
                                              ),
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                  ? "Required"
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),

                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: const TextStyle(fontSize: 15),
                                        decoration: _inputDecoration(
                                          "Email Address",
                                        ),
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                            ? "Required"
                                            : null,
                                      ),
                                      const SizedBox(height: 14),

                                      TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(fontSize: 15),
                                        decoration: _inputDecoration(
                                          "Phone Number",
                                        ),
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                            ? "Required"
                                            : null,
                                      ),
                                      const SizedBox(height: 14),

                                      TextFormField(
                                        controller: _addressController,
                                        style: const TextStyle(fontSize: 15),
                                        decoration: _inputDecoration(
                                          "Shipping Address",
                                        ),
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                            ? "Required"
                                            : null,
                                      ),
                                      const SizedBox(height: 14),

                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: TextFormField(
                                              controller: _aptController,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                              decoration: _inputDecoration(
                                                "Apartment",
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _postcodeController,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                              decoration: _inputDecoration(
                                                "Post Code",
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: _fetchPostageRates,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _cityController,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                              decoration: _inputDecoration(
                                                "City",
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child:
                                                DropdownButtonFormField<String>(
                                                  decoration: _inputDecoration(
                                                    "Select State",
                                                  ),
                                                  items:
                                                      [
                                                            'NSW',
                                                            'VIC',
                                                            'QLD',
                                                            'WA',
                                                            'SA',
                                                            'TAS',
                                                            'ACT',
                                                            'NT',
                                                          ]
                                                          .map(
                                                            (state) =>
                                                                DropdownMenuItem(
                                                                  value: state,
                                                                  child: Text(
                                                                    state,
                                                                  ),
                                                                ),
                                                          )
                                                          .toList(),
                                                  onChanged: (value) {
                                                    _stateController.text =
                                                        value ?? '';
                                                  },
                                                ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 32),

                                      const Text(
                                        "Delivery Options",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      if (_isLoadingRates)
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      else if (_postageRates.isNotEmpty)
                                        Column(
                                          children: _postageRates.map((rate) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              child: _deliveryOption(
                                                label: rate.service,
                                                subtitle: rate.eta.isNotEmpty
                                                    ? 'ETA: ${rate.eta}'
                                                    : '',
                                                value: rate.service
                                                    .toLowerCase(),
                                                price:
                                                    '\$${rate.cost.toStringAsFixed(2)}',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      else
                                        const Text(
                                          'Enter a postcode to see delivery options',
                                          style: TextStyle(color: Colors.grey),
                                        ),

                                      const SizedBox(height: 32),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 58,
                                        child: ElevatedButton(
                                          onPressed: _submitOrder,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF4A306D,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Pay now on terminal",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/visa-icon.svg',
                                                    height: 32,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  SvgPicture.asset(
                                                    'assets/icons/mastercard-icon.svg',
                                                    height: 32,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  SvgPicture.asset(
                                                    'assets/icons/amex-icon.svg',
                                                    height: 32,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 58,
                                        child: OutlinedButton(
                                          onPressed: () {},
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFF7B50C7),
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Pay later with",
                                                style: TextStyle(
                                                  color: Color(0xFF4A306D),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Image.asset(
                                                'assets/icons/ndis-icon.png',
                                                height: 28,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Right side summary
                            Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: Container(
                                width: 350,
                                color: Colors.white,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Summary",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      ...cartItems.map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${item.product.name}...',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                '\$${item.totalPrice.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),
                                      const Divider(),
                                      const SizedBox(height: 12),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Subtotal'),
                                          Text('\$${total.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Shipping'),
                                          Text(
                                            'FREE',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Divider(thickness: 2),
                                      const SizedBox(height: 16),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '\$${total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),

                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _controller.reverse();
                                              Navigator.pop(context);
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.keyboard_backspace_outlined,
                                          ),
                                          label: const Text(
                                            "Return to Cart",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
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
}
