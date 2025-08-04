import 'cart_item.dart';

enum PurchaseStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class Purchase {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final double totalSavings;
  final PurchaseStatus status;
  final DateTime purchaseDate;
  final String? invoiceUrl;
  final String? notes;

  Purchase({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.totalSavings,
    required this.status,
    required this.purchaseDate,
    this.invoiceUrl,
    this.notes,
  });

  // Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Get unique items count
  int get uniqueItemsCount => items.length;

  // Create Purchase from JSON
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
      totalSavings: json['totalSavings'].toDouble(),
      status: PurchaseStatus.values.firstWhere(
        (e) => e.toString() == 'PurchaseStatus.${json['status']}',
      ),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      invoiceUrl: json['invoiceUrl'],
      notes: json['notes'],
    );
  }

  // Convert Purchase to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'totalSavings': totalSavings,
      'status': status.toString().split('.').last,
      'purchaseDate': purchaseDate.toIso8601String(),
      'invoiceUrl': invoiceUrl,
      'notes': notes,
    };
  }

  // Copy with method for creating modified copies
  Purchase copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    double? totalSavings,
    PurchaseStatus? status,
    DateTime? purchaseDate,
    String? invoiceUrl,
    String? notes,
  }) {
    return Purchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      totalSavings: totalSavings ?? this.totalSavings,
      status: status ?? this.status,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      notes: notes ?? this.notes,
    );
  }
} 