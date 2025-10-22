import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_api_service.dart';
import 'services/session_service.dart';
import 'utils/theme.dart';

void main() {
  runApp(const SmartMartApp());
}

class SmartMartApp extends StatelessWidget {
  const SmartMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        title: 'SmartMart',
        theme: AppTheme.lightTheme,
        home: const _AppStart(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _AppStart extends StatefulWidget {
  const _AppStart();

  @override
  State<_AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<_AppStart> {
  @override
  void initState() {
    super.initState();
    _attemptAutoLogin();
  }

  Future<void> _attemptAutoLogin() async {
    try {
      final hasSession = await SessionService.hasSession();
      if (!mounted) return;
      if (hasSession) {
        final phone = await SessionService.getPhoneNumber();
        final pwd = await SessionService.getPassword();
        if (phone != null && pwd != null) {
          try {
            await AuthApiService.login(phoneNumber: phone, password: pwd);
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
            return;
          } catch (_) {
            // fall back to login screen
          }
        }
      }
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (_) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
