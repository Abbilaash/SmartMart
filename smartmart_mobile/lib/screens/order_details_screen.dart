import 'package:flutter/material.dart';
import '../utils/constants.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final products =
        (order['products'] as List?) ?? (order['items'] as List?) ?? [];
    final totalAmount = order['total_amount'] ?? order['total'] ?? 0;
    final originalTotal =
        order['original_total_amount'] ??
        order['original_total'] ??
        totalAmount;
    final savings =
        order['total_savings'] ??
        (originalTotal is num && totalAmount is num
            ? (originalTotal - totalAmount)
            : 0);
    final paymentMethod = (order['payment_method'] ?? '')
        .toString()
        .toUpperCase();
    final customerName = order['customer_name']?.toString() ?? '';
    final orderDate = order['order_date_string']?.toString() ?? '';
    final deliveryStatus = order['delivery_status']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customerName.isNotEmpty)
                    Text(
                      'Customer: $customerName',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  if (orderDate.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Date: $orderDate'),
                  ],
                  if (deliveryStatus.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Delivery: $deliveryStatus'),
                  ],
                  if (paymentMethod.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Payment: $paymentMethod'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Items',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = products[index] as Map<String, dynamic>;
                final name = item['name']?.toString() ?? 'Item';
                final qty = item['quantity'] ?? item['qty'] ?? 1;
                final price = item['discount_price'] ?? item['price'] ?? 0;
                final itemTotal =
                    item['item_total'] ??
                    (price is num ? price * (qty is num ? qty : 1) : 0);
                return ListTile(
                  title: Text(name),
                  subtitle: Text('x$qty'),
                  trailing: Text(
                    '₹${(itemTotal is num ? itemTotal.toStringAsFixed(2) : itemTotal.toString())}',
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _totalRow('Subtotal', '₹${_formatNumber(originalTotal)}'),
                  const SizedBox(height: 8),
                  _totalRow('Savings', '- ₹${_formatNumber(savings)}'),
                  const Divider(height: 24),
                  _totalRow(
                    'Total',
                    '₹${_formatNumber(totalAmount)}',
                    isEmphasis: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(dynamic n) {
    if (n is num) return n.toStringAsFixed(2);
    return n?.toString() ?? '0.00';
  }

  Widget _totalRow(String label, String value, {bool isEmphasis = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isEmphasis ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isEmphasis ? AppColors.primaryPurple : null,
          ),
        ),
      ],
    );
  }
}
