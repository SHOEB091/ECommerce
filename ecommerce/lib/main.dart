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
<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'package:ecommerce/screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'screens/mens_product_list_screen.dart';
import 'screens/womens_product_list_screen.dart';
import 'screens/accessories_product_list_screen.dart';
import 'screens/more_product_list_screen.dart';


void main() {
=======
>>>>>>> 69bddba (admin panel and setting page)
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

<<<<<<< HEAD
=======
>>>>>>> 2b7753b0dca027aa15ac7ca508e40b69ad39c346
>>>>>>> 69bddba (admin panel and setting page)
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
<<<<<<< HEAD
=======

>>>>>>> 69bddba (admin panel and setting page)
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/discover': (context) => const DiscoverPage(),

        // Product lists
        '/mens': (context) => const MensProductListScreen(),
        '/womens': (context) => const WomenProductListScreen(),
        '/accessories': (context) => AccessoriesProductListScreen(),
        '/more': (context) => const MoreProductListScreen(),
<<<<<<< HEAD
=======
<<<<<<< HEAD
        '/settings': (context) => const SettingsPage(),
=======
>>>>>>> 69bddba (admin panel and setting page)

        // Chat & Notifications
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => const NotificationsScreen(),

        // Admin
        '/admin': (context) => AdminPanel(),
<<<<<<< HEAD
=======
>>>>>>> 2b7753b0dca027aa15ac7ca508e40b69ad39c346
>>>>>>> 69bddba (admin panel and setting page)
      },
    );
  }
}
