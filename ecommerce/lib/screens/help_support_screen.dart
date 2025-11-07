// lib/screens/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:ecommerce/screens/home_screen.dart'; // <-- used for navigation back to home

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': 'How can I track my order?',
        'answer':
            'You can track your order by going to the "My Orders" section and selecting the order you want to track.'
      },
      {
        'question': 'How can I reset my password?',
        'answer':
            'Go to the Login screen and tap on "Forgot Password" to receive a reset link on your registered email.'
      },
      {
        'question': 'How can I contact support?',
        'answer':
            'You can reach us by email, phone, or live chat using the options below.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        // Back button that returns to HomeScreen (clears stack and opens home)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Replace stack with HomeScreen so user definitely lands on homepage.
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
          tooltip: 'Back to Home',
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // FAQ ExpansionTiles
          ...faqs.map(
            (faq) => Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      faq['answer']!,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Need More Help?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.email_outlined, color: Colors.blue),
            title: const Text('Email Us'),
            subtitle: const Text('support@yourapp.com'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening email client...')),
              );
              // Add your email launcher here if desired
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined, color: Colors.green),
            title: const Text('Call Us'),
            subtitle: const Text('+91 98765 43210'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening dialer...')),
              );
              // Add your phone dialer logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_outlined, color: Colors.orange),
            title: const Text('Live Chat'),
            subtitle: const Text('Chat with our support team'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting chat...')),
              );
              // Navigate to chat screen if available
            },
          ),

          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback form coming soon...')),
              );
            },
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('Send Feedback'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
