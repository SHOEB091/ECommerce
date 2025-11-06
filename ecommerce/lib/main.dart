import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/screens/welcome_screen.dart';
import 'package:ecommerce/screens/intro_screen.dart';
import 'package:ecommerce/screens/signup_screen.dart';
import 'package:ecommerce/screens/login_screen.dart';
import 'package:ecommerce/screens/discover_page.dart';
import 'package:flutter/material.dart';
import 'screens/mens_product_list_screen.dart';
import 'screens/womens_product_list_screen.dart';
import 'screens/accessories_product_list_screen.dart';
import 'screens/more_product_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GemStore',
      // ✅ Combined Theme
      theme: ThemeData(
        useMaterial3: true, // from dashboard version
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A0A0A)),
        scaffoldBackgroundColor: Colors.white,
      ),

      // ✅ Combined Routing System
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/intro': (context) => const IntroScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/discover': (context) => const DiscoverPage(),
        // Product list routes
        '/mens': (context) => const MensProductListScreen(),
        '/womens': (context) => const WomenProductListScreen(),
        '/accessories': (context) => const AccessoriesProductListScreen(),
        '/more': (context) => const MoreProductListScreen(),
      },
    );
  }
}
