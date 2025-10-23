import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/session_service.dart';
import '../services/payments_api_service.dart';
import '../providers/cart_provider.dart';
import '../widgets/change_password_dialog.dart';
import 'auth/login_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'User';
  String _phoneDisplay = '';
  String _role = '';
  double _totalSpent = 0.0;
  List<Map<String, dynamic>> _payments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await SessionService.getName();
    final phone = await SessionService.getPhoneNumber();
    final role = await SessionService.getRole();
    if (!mounted) return;
    setState(() {
      _name = (name == null || name.isEmpty) ? 'User' : name;
      _phoneDisplay = phone ?? '';
      _role = role ?? '';
    });
    if (phone != null) {
      try {
        final payments = await PaymentsApiService.getPayments(phone);
        double total = 0.0;
        for (final p in payments) {
          final amt = (p['amount'] ?? 0);
          total += (amt is int) ? amt.toDouble() : (amt is double ? amt : 0.0);
        }
        setState(() {
          _payments = payments.reversed.toList(); // oldest to newest for graph
          _totalSpent = total / 100.0; // backend returns paise
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _payments = [];
          _totalSpent = 0.0;
          _loading = false;
        });
      }
    } else {
      setState(() {
        _payments = [];
        _totalSpent = 0.0;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryPurple,
                    child: Icon(Icons.person, size: 50, color: AppColors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _phoneDisplay,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (_role.isNotEmpty)
                    Text(
                      'Role: $_role',
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    color: AppColors.primaryPurple.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Spent',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${_totalSpent.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.trending_up,
                            color: AppColors.primaryPurple,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_payments.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spending Trend (Last 7 Purchases)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              minY: 0,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    for (int i = 0; i < _payments.length; i++)
                                      FlSpot(
                                        i.toDouble(),
                                        ((_payments[i]['amount'] ?? 0) is int
                                                ? (_payments[i]['amount'] ?? 0)
                                                      .toDouble()
                                                : (_payments[i]['amount'] ??
                                                      0.0)) /
                                            100.0,
                                      ),
                                  ],
                                  isCurved: true,
                                  color: AppColors.primaryPurple,
                                  barWidth: 3,
                                  dotData: FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _payments.first['created_at']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _payments.last['created_at']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (_payments.isEmpty)
                    const Text(
                      'No recent payments to show graph.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 32),
                  
                  // Change Password Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ChangePasswordDialog(),
                        );
                      },
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Change Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        // Clear session data
                        await SessionService.clear();
                        
                        // Clear cart data
                        final cartProvider = context.read<CartProvider>();
                        await cartProvider.clearUserData();
                        
                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (_) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
