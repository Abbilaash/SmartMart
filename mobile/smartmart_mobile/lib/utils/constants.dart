import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryPurple = Color(0xFF5e17eb);
  static const Color accentPurple = Color(0xFFa17dff);
  
  // Icon colors
  static const Color activeIconColor = Color(0xFFFFFFFF);
  static const Color inactiveIconColor = Color(0xFFcccccc);
  
  // Text colors
  static const Color textDark = Color(0xFF222222);
  static const Color textLight = Color(0xFF666666);
  static const Color textMuted = Color(0xFF999999);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFf8f8f8);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  
  // Card colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0xFFE0E0E0);
  
  // Status colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);
  
  // Discount colors
  static const Color discountRed = Color(0xFFE53E3E);
  static const Color discountBackground = Color(0xFFFFEBEE);
}

class AppSizes {
  // Padding and margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  
  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  
  // Button heights
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  
  // Card dimensions
  static const double cardElevation = 2.0;
  static const double cardRadius = 12.0;
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );
  
  static const TextStyle price = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryPurple,
  );
  
  static const TextStyle priceOriginal = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    decoration: TextDecoration.lineThrough,
  );
  
  static const TextStyle discount = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.discountRed,
  );
} 