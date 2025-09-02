import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF5e17eb);
  static const Color accentPurple = Color(0xFFa17dff);
  static const Color activeIconColor = Color(0xFFFFFFFF);
  static const Color inactiveIconColor = Color(0xFFCCCCCC);
  static const Color textDarkGrey = Color(0xFF222222);
  static const Color backgroundLight = Color(0xFFF8F8F8);
  static const Color white = Color(0xFFFFFFFF);
}

class AppSizes {
  static const double minTouchTarget = 48.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
}

class AppStrings {
  static const String appName = "SmartMart";
  static const String home = "Home";
  static const String cart = "Cart";
  static const String purchases = "Purchases";
  static const String profile = "Profile";
  static const String discounts = "Discounts";
  static const String scan = "Scan";

  // QR Scanner related strings
  static const String scanProduct = "Scan Product";
  static const String scanInstructions = "Point camera at product QR code";
  static const String scanDescription =
      "Scan products from the offline store to add them to your cart";
  static const String scanButton = "Scan Product QR Code";

  // Instructions
  static const String howToUse = "How to use:";
  static const String step1 = "Visit your local SmartMart store";
  static const String step2 = "Find products with QR codes";
  static const String step3 = "Scan the QR code with this app";
  static const String step4 = "Products will be added to your cart";

  // Stats
  static const String itemsInCart = "Items in Cart";
  static const String totalAmount = "Total Amount";

  // Welcome
  static const String welcomeTitle = "Welcome to SmartMart";
  static const String welcomeSubtitle =
      "Scan QR codes from offline store products to add them to your cart";

  // Billing
  static const String checkout = "Checkout";
  static const String orderSummary = "Order Summary";
  static const String paymentMethod = "Payment Method";
  static const String placeOrder = "Place Order";
  static const String upiPayment = "UPI Payment";
  static const String cashOnCounter = "Cash on Counter";

  // Orders
  static const String purchaseHistory = "Purchase History";
  static const String downloadInvoice = "Download Invoice";
  static const String share = "Share";
}
