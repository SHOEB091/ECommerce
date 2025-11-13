import 'package:flutter/material.dart';
import 'package:ecommerce/screens/home_screen.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _newsletter = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Back button to go back to home page
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
          tooltip: 'Back to Home',
        ),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 800;

        Widget settingsList = ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _settingTile(Icons.person_outline, 'Edit Profile', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile tapped')),
              );
            }),
            _settingTile(Icons.lock_outline, 'Change Password', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change Password tapped')),
              );
            }),
            const Divider(height: 32),

            const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('App Notifications'),
              value: _notifications,
              activeThumbColor: Colors.blue,
              onChanged: (v) => setState(() => _notifications = v),
              secondary: const Icon(Icons.notifications_outlined),
            ),
            SwitchListTile(
              title: const Text('Newsletter Subscription'),
              value: _newsletter,
              activeThumbColor: Colors.blue,
              onChanged: (v) => setState(() => _newsletter = v),
              secondary: const Icon(Icons.email_outlined),
            ),
            const Divider(height: 32),

            const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkMode,
              activeThumbColor: Colors.blue,
              onChanged: (v) => setState(() => _darkMode = v),
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
            const Divider(height: 32),

            const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _settingTile(Icons.info_outline, 'App Version: 1.0.0'),
            _settingTile(Icons.policy_outlined, 'Privacy Policy', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy tapped')),
              );
            }),
            _settingTile(Icons.description_outlined, 'Terms & Conditions', onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms & Conditions tapped')),
              );
            }),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Log out tapped')),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );

        if (isDesktop) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                margin: const EdgeInsets.all(24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: settingsList,
              ),
            ),
          );
        } else {
          return SafeArea(child: settingsList);
        }
      }),
    );
  }

  Widget _settingTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
