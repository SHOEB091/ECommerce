// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Screens
import 'package:ecommerce/screens/welcome_screen.dart';
import 'package:ecommerce/screens/intro_screen.dart';
import 'package:ecommerce/screens/signup_screen.dart';
import 'package:ecommerce/screens/login_screen.dart';
import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/screens/discover_page.dart';
import 'package:ecommerce/screens/mens_product_list_screen.dart';
import 'package:ecommerce/screens/womens_product_list_screen.dart';
import 'package:ecommerce/screens/accessories_product_list_screen.dart';
import 'package:ecommerce/screens/more_product_list_screen.dart';
import 'package:ecommerce/screens/chat_screen.dart';
import 'package:ecommerce/screens/notifications_screen.dart';

// Admin (from feature branch)
import 'package:ecommerce/screens/admin/admin_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (e.g. GEMINI_API_KEY) from .env at project root
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GemStore',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A0A0A)),
        scaffoldBackgroundColor: Colors.white,
      ),

      // Routing
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/intro': (context) => const IntroScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/discover': (context) => const DiscoverPage(),

        // Product lists
        '/mens': (context) => const MensProductListScreen(),
        '/womens': (context) => const WomenProductListScreen(),
        '/accessories': (context) => AccessoriesProductListScreen(),
        '/more': (context) => const MoreProductListScreen(),

        // Chat & Notifications
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => const NotificationsScreen(),

        // Admin
        '/admin': (context) => AdminPanel(),
      },
    );
  }
}
