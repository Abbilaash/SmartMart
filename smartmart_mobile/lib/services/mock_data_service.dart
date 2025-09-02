import '../models/product.dart';
import '../models/discount.dart';

class MockDataService {
  static List<Product> getProducts() {
    return [
      Product(
        id: '1',
        name: 'Fresh Apples',
        image:
            'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
        originalPrice: 2.99,
        discountPrice: 1.99,
        stock: 50,
        category: 'Fruits',
        description: 'Fresh red apples from local farms',
      ),
      Product(
        id: '2',
        name: 'Organic Milk',
        image:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
        originalPrice: 3.49,
        stock: 30,
        category: 'Dairy',
        description: 'Organic whole milk',
      ),
      Product(
        id: '3',
        name: 'Whole Grain Bread',
        image:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
        originalPrice: 2.49,
        discountPrice: 1.99,
        stock: 25,
        category: 'Bakery',
        description: 'Fresh whole grain bread',
      ),
      Product(
        id: '4',
        name: 'Fresh Tomatoes',
        image:
            'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400',
        originalPrice: 1.99,
        stock: 40,
        category: 'Vegetables',
        description: 'Ripe red tomatoes',
      ),
      Product(
        id: '5',
        name: 'Chicken Breast',
        image:
            'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400',
        originalPrice: 8.99,
        discountPrice: 6.99,
        stock: 20,
        category: 'Meat',
        description: 'Fresh chicken breast',
      ),
      Product(
        id: '6',
        name: 'Greek Yogurt',
        image:
            'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
        originalPrice: 4.49,
        stock: 35,
        category: 'Dairy',
        description: 'Creamy Greek yogurt',
      ),
    ];
  }

  static List<Discount> getDiscounts() {
    return [
      Discount(
        id: '1',
        title: 'Fruits & Vegetables Sale',
        description: 'Get 20% off on all fresh fruits and vegetables',
        percentage: 20,
        minimumPurchase: 10.0,
        validUntil: DateTime.now().add(const Duration(days: 7)),
        category: 'Fruits & Vegetables',
      ),
      Discount(
        id: '2',
        title: 'Dairy Products Discount',
        description:
            '15% off on all dairy products including milk, yogurt, and cheese',
        percentage: 15,
        minimumPurchase: 5.0,
        validUntil: DateTime.now().add(const Duration(days: 5)),
        category: 'Dairy',
      ),
      Discount(
        id: '3',
        title: 'Bakery Special',
        description:
            'Buy any 2 bakery items and get 25% off on the second item',
        percentage: 25,
        minimumPurchase: 0.0,
        validUntil: DateTime.now().add(const Duration(days: 3)),
        category: 'Bakery',
      ),
      Discount(
        id: '4',
        title: 'Meat & Poultry Deal',
        description: 'Special pricing on all meat and poultry products',
        percentage: 10,
        minimumPurchase: 15.0,
        validUntil: DateTime.now().add(const Duration(days: 10)),
        category: 'Meat',
      ),
    ];
  }
}
