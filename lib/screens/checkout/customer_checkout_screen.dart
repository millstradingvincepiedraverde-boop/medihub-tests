import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  Future<void> _fetchPostageRates(String postcode) async {
    if (postcode.length < 4) return;
    setState(() => _isLoadingRates = true);
    _postageRates.clear();

    try {
      for (final item in _orderService.cartItems) {
        final sku = item.product.sku;
        final qty = item.quantity;
        final rates = await _postageController.fetchRates(sku, postcode, qty);
        if (rates.isNotEmpty) {
          _postageRates.addAll(rates);
        }
      }

      _postageRates.sort((a, b) => a.cost.compareTo(b.cost));
      setState(() => _isLoadingRates = false);
    } catch (e) {
      debugPrint('❌ Failed to fetch postage rates: $e');
      setState(() => _isLoadingRates = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final cartItems = _orderService.cartItems;
    final total = _orderService.cartTotal;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: isMobile ? size.height * 0.95 : size.height * 0.85,
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
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Checkout",
                              style: TextStyle(
                                fontSize: isMobile ? 26 : 36,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 28),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Responsive layout
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: isMobile
                                ? Column(
                                    children: [
                                      _buildFormSection(isMobile),
                                      const SizedBox(height: 20),
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
                                      const SizedBox(width: 20),
                                      SizedBox(
                                        width: 350,
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

  // --- Components below ---
  Widget _buildFormSection(bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Details",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: _inputDecoration("First Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: _inputDecoration("Last Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration("Email Address"),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration("Phone Number"),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _addressController,
            decoration: _inputDecoration("Shipping Address"),
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _aptController,
                  decoration: _inputDecoration("Apartment"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _postcodeController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration("Post Code"),
                  onChanged: _fetchPostageRates,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _isLoadingRates
              ? const Center(child: CircularProgressIndicator())
              : _postageRates.isEmpty
              ? const Text(
                  "Enter postcode to view delivery options",
                  style: TextStyle(color: Colors.grey),
                )
              : Column(
                  children: _postageRates
                      .map(
                        (r) => ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _deliveryMethod == r.service
                                  ? Colors.deepPurple
                                  : Colors.grey.shade300,
                            ),
                          ),
                          title: Text(r.service),
                          subtitle: r.eta.isNotEmpty
                              ? Text("ETA: ${r.eta}")
                              : null,
                          trailing: Text("\$${r.cost.toStringAsFixed(2)}"),
                          onTap: () =>
                              setState(() => _deliveryMethod = r.service),
                        ),
                      )
                      .toList(),
                ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A306D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Pay Now on Terminal",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 🛒 Cart items
          ...cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.product.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                ],
              ),
            );
          }),

          const Divider(),

          // 💰 Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal"),
              Text('\$${total.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),

          // 🚚 Shipping
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Shipping"),
              Text(
                shippingCost == 0
                    ? "FREE"
                    : "\$${shippingCost.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const Divider(thickness: 1.5),

          // 🧾 Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 💳 Payment Method Logos
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 10,
              children: [
                SvgPicture.asset('assets/icons/paypal.svg', height: 28),
                SvgPicture.asset('assets/icons/mastercard.svg', height: 28),
                SvgPicture.asset('assets/icons/amex.svg', height: 28),
                SvgPicture.asset('assets/icons/ndis.svg', height: 32),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Center(
            child: Text(
              "We accept PayPal, Mastercard, Amex & NDIS payments",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
