import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../services/barcode_scanner_service.dart';
import '../services/order_api_service.dart'; // Added import for OrderApiService
import '../utils/api_config.dart'; // Added import for ApiConfig

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  String selectedPaymentMethod = 'upi';
  bool isProcessing = false;
  final _formKey = GlobalKey<FormState>(); // Added form key
  final _deliveryAddressController = TextEditingController(); // Added delivery address controller

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...cartProvider.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(item.product.name),
                          ),
                          Text('x${item.quantity}'),
                          const SizedBox(width: 16),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Method Selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentOption(
                      'upi',
                      'UPI Payment',
                      'Pay using UPI apps like Google Pay, PhonePe',
                      Icons.account_balance_wallet,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      'cash',
                      'Cash on Counter',
                      'Pay at the counter when collecting items',
                      Icons.money,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Delivery Address Form
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Address',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _deliveryAddressController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your delivery address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your delivery address';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Place Order Button
            ElevatedButton(
              onPressed: isProcessing ? null : () => _placeOrder(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, String subtitle, IconData icon) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPaymentMethod == value 
              ? AppColors.primaryPurple 
              : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedPaymentMethod == value 
                ? AppColors.primaryPurple 
                : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedPaymentMethod == value 
                        ? AppColors.primaryPurple 
                        : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (selectedPaymentMethod == value)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryPurple,
              ),
          ],
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context) async {
    setState(() {
      isProcessing = true;
    });

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) {
      setState(() {
        isProcessing = false;
      });
      return;
    }

    try {
      final cartProvider = context.read<CartProvider>();
      final deliveryAddress = _deliveryAddressController.text.trim();
      
      // Call the order API service
      final orderResponse = await OrderApiService.placeOrder(
        phoneNumber: ApiConfig.defaultPhoneNumber,
        paymentMethod: selectedPaymentMethod,
        deliveryAddress: deliveryAddress,
      );

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Order placed successfully! Order ID: ${orderResponse['order_id']}'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear cart and navigate back to main screen
        cartProvider.clear();
        navigator.popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error placing order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }
}