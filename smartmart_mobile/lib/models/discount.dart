class Discount {
  final String id;
  final String title;
  final String description;
  final int percentage;
  final double minimumPurchase;
  final DateTime validUntil;
  final String category;

  Discount({
    required this.id,
    required this.title,
    required this.description,
    required this.percentage,
    required this.minimumPurchase,
    required this.validUntil,
    required this.category,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      percentage: json['percentage'],
      minimumPurchase: json['minimumPurchase'].toDouble(),
      validUntil: DateTime.parse(json['validUntil']),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'percentage': percentage,
      'minimumPurchase': minimumPurchase,
      'validUntil': validUntil.toIso8601String(),
      'category': category,
    };
  }
}