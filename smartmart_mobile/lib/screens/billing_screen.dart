import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../services/order_api_service.dart';
import '../services/payment_service.dart';
import '../services/session_service.dart';
import 'payment_webview_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  String selectedPaymentMethod = 'upi';
  bool isProcessing = false;
  final _billingAddressController = TextEditingController();
  

  @override
  void dispose() {
    _billingAddressController.dispose();
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
      // Move the Place Order button to bottomNavigationBar to avoid bottom overflow
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: ElevatedButton(
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
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text(
                    'Place Order',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                    ...cartProvider.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(item.product.name)),
                            Text('x${item.quantity}'),
                            const SizedBox(width: 16),
                            Text(
                              '₹${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                          '₹${cartProvider.totalAmount.toStringAsFixed(2)}',
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
                      'card',
                      'Pay via Card',
                      'Pay using credit or debit card',
                      Icons.credit_card,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Card details are collected by Stripe Checkout; no in-app card form

            const SizedBox(height: 24),

            // Billing Address Form
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
                      'Billing Address',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _billingAddressController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your billing address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.receipt_long),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your billing address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // No delivery address; only billing address is needed

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (selectedPaymentMethod == value)
              const Icon(Icons.check_circle, color: AppColors.primaryPurple),
          ],
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context) async {
    setState(() {
      isProcessing = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    if (_billingAddressController.text.trim().isEmpty) {
      setState(() {
        isProcessing = false;
      });
      return;
    }

    try {
      final cartProvider = context.read<CartProvider>();
      final billingAddress = _billingAddressController.text.trim();

      // Ensure billing address is not empty
      if (billingAddress.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Please enter your billing address'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isProcessing = false;
        });
        return;
      }

      // Validate minimum amount for UPI payment
      if (selectedPaymentMethod == 'upi') {
        if (!PaymentService.isValidAmount(cartProvider.totalAmount)) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Minimum amount for UPI payment is ₹0.01'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isProcessing = false;
          });
          return;
        }

        // Process UPI payment
        await _processUpiPayment(cartProvider, billingAddress);
      } else if (selectedPaymentMethod == 'card') {
        // Start Stripe card payment
        await _processCardPayment(
          cartProvider,
          billingAddress,
        );
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

  Future<void> _processUpiPayment(
    CartProvider cartProvider,
    String billingAddress,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Get current user's phone number
      final phoneNumber = await SessionService.getPhoneNumber();
      if (phoneNumber == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create payment session
      final paymentResult = await PaymentService.processUpiPayment(
        amount: cartProvider.totalAmount,
        userId: phoneNumber,
        orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        billingAddress: billingAddress,
      );

      if (!paymentResult['success']) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Payment failed: ${paymentResult['error'] ?? 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate required payment data
      final paymentUrl = paymentResult['payment_url'];
      final sessionId = paymentResult['session_id'];

      // Debug: Print the payment result to understand what we're getting
      print('Payment result received: $paymentResult');
      print('Payment URL: $paymentUrl, Session ID: $sessionId');

      if (paymentUrl == null || sessionId == null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Payment session data is incomplete. Missing: ${paymentUrl == null ? 'payment_url ' : ''}${sessionId == null ? 'session_id' : ''}\nReceived: ${paymentResult.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }

      // Navigate to payment screen
      final paymentCompleted = await navigator.push<bool>(
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(
            paymentUrl: paymentUrl,
            sessionId: sessionId,
            onPaymentComplete: (success, message) {
              if (success && message != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ),
      );

      // If payment was completed, place the order
      if (paymentCompleted == true) {
        await _placeOrderAfterPayment(
          cartProvider,
          billingAddress,
          paymentResult,
          paymentMode: 'UPI',
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processCardPayment(
    CartProvider cartProvider,
    String billingAddress,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Get current user's phone number
      final phoneNumber = await SessionService.getPhoneNumber();
      if (phoneNumber == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final result = await PaymentService.processCardPayment(
        amount: cartProvider.totalAmount,
        userId: phoneNumber,
        orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        billingAddress: billingAddress,
      );

      if (!result['success']) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final paymentUrl = result['payment_url'];
      final sessionId = result['session_id'];
      if (paymentUrl == null || sessionId == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Payment session is incomplete'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final navigator = Navigator.of(context);
      final completed = await navigator.push<bool>(
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(
            paymentUrl: paymentUrl,
            sessionId: sessionId,
            onPaymentComplete: (_, __) {},
          ),
        ),
      );

      if (completed == true) {
        await _placeOrderAfterPayment(
          cartProvider,
          billingAddress,
          result,
          paymentMode: 'Card',
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error with card payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _placeOrderAfterPayment(
    CartProvider cartProvider,
    String billingAddress,
    Map<String, dynamic> paymentResult,
    {required String paymentMode}
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Get current user's phone number
      final phoneNumber = await SessionService.getPhoneNumber();
      if (phoneNumber == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Place order after successful payment
      final orderResponse = await OrderApiService.placeOrder(
        phoneNumber: phoneNumber,
        paymentMethod: paymentMode.toLowerCase(),
        billingAddress: billingAddress,
      );

      if (mounted) {
        final orderId = orderResponse['order_id'] ?? 'Unknown';
        messenger.showSnackBar(
          SnackBar(
            content: Text('Order placed successfully! Order ID: $orderId'),
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
            content: Text('Error placing order after payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
