import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cart_item.dart';
import '../utils/constants.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              child: CachedNetworkImage(
                imageUrl: cartItem.product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.backgroundLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: AppColors.backgroundLight,
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.paddingMedium),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    cartItem.product.name,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${cartItem.product.currentPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.price.copyWith(fontSize: 16),
                      ),
                      if (cartItem.hasDiscount) ...[
                        SizedBox(width: 4),
                        Text(
                          '\$${cartItem.product.originalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.priceOriginal.copyWith(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8),

                  // Quantity Controls
                  Row(
                    children: [
                      // Decrease Button
                      GestureDetector(
                        onTap: () => onQuantityChanged(cartItem.quantity - 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            border: Border.all(color: AppColors.cardShadow),
                          ),
                          child: Icon(
                            Icons.remove,
                            size: 16,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.paddingSmall),

                      // Quantity Display
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${cartItem.quantity}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.paddingSmall),

                      // Increase Button
                      GestureDetector(
                        onTap: () => onQuantityChanged(cartItem.quantity + 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.paddingMedium),

            // Total Price and Remove Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Total Price
                Text(
                  '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.price.copyWith(fontSize: 16),
                ),
                SizedBox(height: 8),

                // Remove Button
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 