import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/discover_page.dart';
import 'screens/mens_product_list_screen.dart';
import 'screens/womens_product_list_screen.dart';
import 'screens/accessories_product_list_screen.dart';
import 'screens/more_product_list_screen.dart';
import 'screens/settings_page.dart';
import 'screens/chat_screen.dart';
import 'screens/admin/admin_panel.dart';
import 'screens/notifications_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/intro': (context) => const WelcomeScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/discover': (context) => const DiscoverPage(),
        '/mens': (context) => const MensProductListScreen(),
        '/womens': (context) => const WomenProductListScreen(),
        '/accessories': (context) => const AccessoriesProductListScreen(),
        '/more': (context) => const MoreProductListScreen(),
        '/settings': (context) => const SettingsPage(),
        '/chat': (context) => const ChatScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/admin': (context) => const AdminPanel(),
      },
    );
  }
}
