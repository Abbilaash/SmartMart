import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase History'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_outlined,
              size: 80,
              color: AppColors.textMuted,
            ),
            SizedBox(height: AppSizes.paddingLarge),
            Text(
              'No purchases yet',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: AppSizes.paddingSmall),
            Text(
              'Your purchase history will appear here',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: AppSizes.paddingLarge),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }
} 