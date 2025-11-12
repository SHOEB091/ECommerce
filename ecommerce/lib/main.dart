// lib/main.dart
import 'package:ecommerce/screens/cart_screen.dart';
import 'package:ecommerce/screens/signup_screen.dart';
import 'package:ecommerce/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Screens
import 'package:ecommerce/screens/welcome_screen.dart';
import 'package:ecommerce/screens/intro_screen.dart';
import 'package:ecommerce/screens/login_screen.dart';
import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/screens/discover_page.dart';
import 'package:ecommerce/screens/settings_page.dart';
import 'package:ecommerce/screens/mens_product_list_screen.dart';
import 'package:ecommerce/screens/womens_product_list_screen.dart';
import 'package:ecommerce/screens/accessories_product_list_screen.dart';
import 'package:ecommerce/screens/more_product_list_screen.dart';
import 'package:ecommerce/screens/chat_screen.dart';
import 'package:ecommerce/screens/notofications_screen.dart';

// Admin (optional)
import 'package:ecommerce/screens/admin/admin_panel.dart';

// Notifications service (ensure this file exists and implements init())
import 'package:ecommerce/services/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications (loads persisted notifications if service supports it)
  try {
    await NotificationsService.instance.init();
    debugPrint('✅ NotificationsService initialized');
  } catch (e) {
    debugPrint('⚠️ NotificationsService init failed: $e');
  }

await CartService.instance.init();
debugPrint('✅ CartService initialized');
  // Load .env: different path on web vs mobile if you keep .env under assets for web builds
  final envPath = kIsWeb ? 'assets/.env' : '.env';
  try {
    await dotenv.load(fileName: envPath);
    debugPrint('✅ dotenv loaded from: $envPath');
  } catch (e) {
    debugPrint('⚠️ dotenv failed to load from $envPath: $e');
    // fallback attempts
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('✅ dotenv fallback loaded from: .env');
    } catch (_) {
      try {
        await dotenv.load(fileName: 'assets/.env');
        debugPrint('✅ dotenv fallback loaded from: assets/.env');
      } catch (_) {
        debugPrint('⚠️ dotenv fallback attempts failed.');
      }
    }
  }
  

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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/intro': (context) => const IntroScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // '/discover': (context) => const DiscoverPage(),
        // '/mens': (context) => const MensProductListScreen(),
        // '/womens': (context) => const WomenProductListScreen(),
        '/accessories': (context) => AccessoriesProductListScreen(),
        // '/more': (context) => const MoreProductListScreen(),
        '/settings': (context) => const SettingsPage(),
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/admin': (context) => AdminPanel(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}