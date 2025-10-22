import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String sessionId;
  final Function(bool success, String? message) onPaymentComplete;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.sessionId,
    required this.onPaymentComplete,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  bool isCheckingStatus = false;
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    // Auto-open the Stripe checkout URL when the screen opens (if provided)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_launched && widget.paymentUrl.isNotEmpty) {
        _openStripeCheckout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPaymentStatus,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 80, color: AppColors.primaryPurple),
            const SizedBox(height: 24),
            const Text(
              'Complete Your Payment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please complete your payment using the Stripe payment interface.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Payment URL Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment URL:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.paymentUrl,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () =>
                                _copyToClipboard(widget.paymentUrl),
                            tooltip: 'Copy URL',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Copy the payment URL above'),
                    Text('2. Open it in your browser'),
                    Text('3. Complete the payment using your preferred method'),
                    Text('4. Return here and tap "Check Payment Status"'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Open Stripe Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openStripeCheckout,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open Stripe Checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Check Payment Status Button (responsive)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCheckingStatus ? null : _checkPaymentStatus,
                icon: isCheckingStatus
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Flexible(
                  child: Text(
                    isCheckingStatus
                        ? 'Checking Payment Status...'
                        : 'Check Payment Status',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel Payment',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment URL copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openStripeCheckout() async {
    if (widget.paymentUrl.isEmpty) return;
    try {
      final uri = Uri.parse(widget.paymentUrl);
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          // Fallback to in-app browser view
          final inApp = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          if (!inApp) {
            throw Exception('Device cannot open URL');
          }
        }
        setState(() {
          _launched = true;
        });
      } else {
        // Fallback to in-app browser view directly
        final inApp = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        if (!inApp) {
          throw Exception('Device cannot open URL');
        }
        setState(() {
          _launched = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkPaymentStatus() async {
    if (isCheckingStatus) return;

    setState(() {
      isCheckingStatus = true;
    });

    try {
      final result = await PaymentService.checkPaymentStatus(widget.sessionId);

        if (result['success']) {
        final paymentData = result['data'];
        // Support both fields from backend: checkout_payment_status and payment_status
        final paymentStatus = (paymentData['payment_status'] ?? paymentData['checkout_payment_status'])?.toString();

        if (paymentStatus == 'paid' || paymentStatus == 'Completed' || paymentStatus == 'succeeded' || paymentData['payment_completed'] == true) {
          widget.onPaymentComplete(true, 'Payment completed successfully!');
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Payment is still pending. Please complete the payment first.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error checking payment: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isCheckingStatus = false;
        });
      }
    }
  }
}
