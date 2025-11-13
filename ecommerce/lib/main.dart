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
import 'package:ecommerce/screens/settings_page.dart';
import 'package:ecommerce/screens/accessories_product_list_screen.dart';
import 'package:ecommerce/screens/chat_screen.dart';
import 'package:ecommerce/screens/notofications_screen.dart';

// Admin (optional)
import 'package:ecommerce/screens/admin/admin_panel.dart';

// Notifications service (ensure this file exists and implements init())
import 'package:ecommerce/services/notifications_service.dart';

// Secure storage to read saved JWT token
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications (loads persisted notifications if service supports it)
  try {
    await NotificationsService.instance.init();
    debugPrint('✅ NotificationsService initialized');
  } catch (e) {
    debugPrint('⚠️ NotificationsService init failed: $e');
  }

  // Configure CartService to match your backend routing.
  // Your server exposes cart routes under "/api/v1/cart" so we set apiPrefix to '/api/v1'.
  try {
    CartService.instance.configure(apiPrefix: '/api/v1', port: 5000, host: 'localhost');
    debugPrint('✅ CartService configured (apiPrefix=/api/v1, port=5000, host=localhost)');
  } catch (e) {
    debugPrint('⚠️ CartService configure error: $e');
  }

  // Try to read saved token from secure storage and initialize CartService with it.
  try {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      await CartService.instance.init(token: token);
      debugPrint('✅ CartService initialized with saved token');
    } else {
      // Still call init() without token so CartService will fetch empty cart / be ready.
      await CartService.instance.init();
      debugPrint('ℹ️ CartService initialized without token (no saved token found)');
    }
  } catch (e) {
    debugPrint('⚠️ CartService init error: $e');
    // ensure CartService is at least initialized so UI relying on it doesn't crash
    try {
      await CartService.instance.init();
    } catch (_) {}
  }

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
        '/accessories': (context) => AccessoriesProductListScreen(),
        '/settings': (context) => const SettingsPage(),
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/admin': (context) => AdminPanel(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}
