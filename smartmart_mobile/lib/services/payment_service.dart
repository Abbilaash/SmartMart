import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class PaymentService {
  // Create payment session using our backend API
  static Future<Map<String, dynamic>> createPaymentSession({
    required double amount,
    required String userId,
    String? orderId,
    String? billingAddress,
    String paymentMethod = 'upi',
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/users/create-payment-session',
      );

      // Send amount with explicit unit to avoid double conversion
      final amountValue = amount; // in rupees

      print('Creating payment session with amount: ₹$amount');

      final requestBody = {
        'amount': amountValue,
        'user_id': userId,
        'order_id': orderId,
        'payment_method': paymentMethod,
        'amount_unit': 'rupees',
      };

      // Add billing address if provided
      if (billingAddress != null && billingAddress.isNotEmpty) {
        requestBody['billing_address'] = billingAddress;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Payment session response status: ${response.statusCode}');
      print('Payment session response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Payment session creation failed',
        };
      }
    } catch (e) {
      print('Payment session creation error: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Check payment status
  static Future<Map<String, dynamic>> checkPaymentStatus(
    String sessionId,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/users/payment-status/$sessionId',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to check payment status',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Process UPI payment flow
  static Future<Map<String, dynamic>> processUpiPayment({
    required double amount,
    required String userId,
    String? orderId,
    String? billingAddress,
  }) async {
    try {
      // Create payment session
      final sessionResult = await createPaymentSession(
        amount: amount,
        userId: userId,
        orderId: orderId,
        billingAddress: billingAddress,
        paymentMethod: 'upi',
      );

      if (!sessionResult['success']) {
        return sessionResult;
      }

      final sessionData = sessionResult['data'];

      // Debug: Print the session data to understand what we're getting
      print('Session data received: $sessionData');

      // Get payment URL and session id - try multiple field names and nested objects
      String? paymentUrl;
      String? sessionId;

      // helper to extract keys from a map
      String? tryKeys(Map m, List<String> keys) {
        for (final k in keys) {
          if (m.containsKey(k) && m[k] != null) return m[k].toString();
        }
        return null;
      }

      if (sessionData is Map) {
        paymentUrl = tryKeys(sessionData, [
          'payment_url',
          'url',
          'checkout_url',
          'checkout_url',
          'paymentUrl',
        ]);
        sessionId = tryKeys(sessionData, [
          'session_id',
          'id',
          'stripe_session',
          'checkout_session',
        ]);

        // If not found, try nested maps
        if ((paymentUrl == null || sessionId == null)) {
          for (final v in sessionData.values) {
            if (v is Map) {
              paymentUrl ??= tryKeys(v, [
                'payment_url',
                'url',
                'checkout_url',
                'paymentUrl',
              ]);
              sessionId ??= tryKeys(v, [
                'session_id',
                'id',
                'stripe_session',
                'checkout_session',
              ]);
            }
          }
        }
      }

      // Final check
      if (paymentUrl == null || sessionId == null) {
        return {
          'success': false,
          'error':
              'Missing payment URL or session ID in response. Got: $sessionData',
          'raw': sessionData,
        };
      }

      return {
        'success': true,
        'session_id': sessionId,
        'payment_url': paymentUrl,
        'client_secret': sessionData is Map
            ? sessionData['client_secret']
            : null,
        'amount': sessionData is Map ? sessionData['amount'] : null,
        'currency': sessionData is Map ? sessionData['currency'] : null,
        'order_id': sessionData is Map ? sessionData['order_id'] : null,
        'message': 'Payment session created successfully.',
      };
    } catch (e) {
      return {'success': false, 'error': 'Payment processing failed: $e'};
    }
  }

  // Simulate cash payment (for counter payment)
  static Future<Map<String, dynamic>> processCashPayment() async {
    // For cash payment, we just return success since it's paid at counter
    return {
      'success': true,
      'payment_method': 'cash',
      'message': 'Order placed successfully. Please pay at the counter.',
    };
  }

  // Process card payment with card details
  static Future<Map<String, dynamic>> processCardPayment({
    required double amount,
    required String userId,
    String? orderId,
    String? billingAddress,
  }) async {
    try {
      final sessionResult = await createPaymentSession(
        amount: amount,
        userId: userId,
        orderId: orderId,
        billingAddress: billingAddress,
        paymentMethod: 'card',
      );

      return sessionResult;
    } catch (e) {
      return {'success': false, 'error': 'Payment processing failed: $e'};
    }
  }

  // Validate payment amounts
  static bool isValidAmount(double amount) {
    // Minimum amount should be ₹0.50 (50 paise) - lowered for testing
    return amount >= 0.01;
  }

  // Format amount for display
  static String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Convert paise to rupees for display
  static double paiseToRupees(int paise) {
    return paise / 100.0;
  }

  // Convert rupees to paise for API
  static int rupeesToPaise(double rupees) {
    return (rupees * 100).toInt();
  }
}
