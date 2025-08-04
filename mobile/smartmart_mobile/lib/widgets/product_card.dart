import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Discount Badge
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSizes.cardRadius),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: AppColors.backgroundLight,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.backgroundLight,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                // Discount Badge
                if (product.hasDiscount)
                  Positioned(
                    top: AppSizes.paddingSmall,
                    right: AppSizes.paddingSmall,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSmall,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.discountRed,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Text(
                        '${product.calculatedDiscountPercentage?.round()}% OFF',
                        style: AppTextStyles.discount.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Product Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Price Section
                  Row(
                    children: [
                      // Current Price
                      Text(
                        '\$${product.currentPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.price.copyWith(fontSize: 16),
                      ),
                      SizedBox(width: 4),
                      // Original Price (if discounted)
                      if (product.hasDiscount)
                        Text(
                          '\$${product.originalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.priceOriginal.copyWith(fontSize: 12),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Add to Cart Button
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 