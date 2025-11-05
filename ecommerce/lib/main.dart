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
      title: "E-Commerce UI",
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛍️ FluxStore UI")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("👕 Men's Collection"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MensProductListScreen())),
          ),
          ListTile(
            title: const Text("👗 Women's Collection"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const WomenProductListScreen())),
          ),
          ListTile(
            title: const Text("🕶️ Accessories"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>  AccessoriesProductListScreen())),
          ),
          ListTile(
            title: const Text("🧴 More Items"),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MoreProductListScreen())),
          ),
        ],
      ),
    );
  }
}
