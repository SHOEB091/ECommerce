// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
import 'package:ecommerce/screens/notofications_screen.dart';

// Admin (optional — keep if file exists)
import 'package:ecommerce/screens/admin/admin_panel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final envPath = kIsWeb ? 'assets/.env' : '.env';
  try {
    await dotenv.load(fileName: envPath);
    debugPrint('✅ dotenv loaded from: $envPath');
  } catch (e) {
    debugPrint('⚠️ dotenv failed to load from $envPath: $e');
    // Try fallback to the other path just in case
    if (kIsWeb) {
      try {
        await dotenv.load(fileName: '.env');
        debugPrint('✅ dotenv fallback loaded from: .env');
      } catch (_) {
        debugPrint('⚠️ dotenv fallback also failed.');
      }
    } else {
      try {
        await dotenv.load(fileName: 'assets/.env');
        debugPrint('✅ dotenv fallback loaded from: assets/.env');
      } catch (_) {
        debugPrint('⚠️ dotenv fallback also failed.');
      }
    }
  }

  // Quick debug-check: print a small subset (don't leak secrets in logs for release)
  final geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '<missing>';
  final geminiModel = dotenv.env['GEMINI_MODEL'] ?? '<missing>';
  debugPrint('GEMINI_API_KEY present: ${geminiApiKey != '<missing>'}');
  debugPrint('GEMINI_MODEL: $geminiModel');
  // ---------------------------------------

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
        '/discover': (context) => const DiscoverPage(),
        '/mens': (context) => const MensProductListScreen(),
        '/womens': (context) => const WomenProductListScreen(),
        '/accessories': (context) => AccessoriesProductListScreen(),
        '/more': (context) => const MoreProductListScreen(),
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/admin': (context) => AdminPanel(),
      },
    );
  }
}
