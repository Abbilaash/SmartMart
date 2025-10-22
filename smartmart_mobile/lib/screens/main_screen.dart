import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'discounts_screen.dart';
import 'cart_screen.dart';
import 'purchases_screen.dart';
import 'profile_screen.dart';
import '../widgets/smartmart_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2; // Center tab (Home)

  final List<Widget> _screens = [
    const DiscountsScreen(), // 0
    const CartScreen(), // 1
    const HomeScreen(), // 2 (center)
    const PurchasesScreen(), // 3
    const ProfileScreen(), // 4 (rightmost)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SmartMartNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
