import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.isEmpty) return SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  _showClearCartDialog(context);
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return _buildEmptyCart();
          }
          return _buildCartContent(context, cart);
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textMuted,
          ),
          SizedBox(height: AppSizes.paddingLarge),
          Text(
            'Your cart is empty',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Add some products to get started',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartProvider cart) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              return CartItemWidget(
                cartItem: cart.items[index],
                onQuantityChanged: (quantity) {
                  cart.updateQuantity(cart.items[index].product.id, quantity);
                },
                onRemove: () {
                  cart.removeItem(cart.items[index].product.id);
                },
              );
            },
          ),
        ),

        // Cart Summary
        Container(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Summary Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: AppTextStyles.body1),
                  Text('\$${cart.subtotal.toStringAsFixed(2)}', style: AppTextStyles.body1),
                ],
              ),
              if (cart.totalSavings > 0) ...[
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Savings', style: AppTextStyles.body2.copyWith(color: AppColors.discountRed)),
                    Text('-\$${cart.totalSavings.toStringAsFixed(2)}', 
                         style: AppTextStyles.body2.copyWith(color: AppColors.discountRed)),
                  ],
                ),
              ],
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax (8%)', style: AppTextStyles.body2),
                  Text('\$${cart.tax.toStringAsFixed(2)}', style: AppTextStyles.body2),
                ],
              ),
              Divider(height: AppSizes.paddingMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyles.heading3),
                  Text('\$${cart.total.toStringAsFixed(2)}', style: AppTextStyles.price),
                ],
              ),
              SizedBox(height: AppSizes.paddingMedium),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showCheckoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
                  ),
                  child: Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cart'),
        content: Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.of(context).pop();
            },
            child: Text('Clear', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Checkout'),
        content: Text('Checkout functionality will be implemented in the next phase.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
} 