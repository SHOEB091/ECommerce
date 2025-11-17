import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/screens/profile_setting_page.dart';
import '../services/user_service.dart';
import '../utils/api.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _newsletter = false;
  Map<String, dynamic>? _user;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadUser();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('pref_dark_mode') ?? false;
      _notifications = prefs.getBool('pref_notifications') ?? true;
      _newsletter = prefs.getBool('pref_newsletter') ?? false;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _loadUser() async {
    final user = await UserService.instance.ensureUserLoaded();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loadingUser = false;
    });
  }

  Future<void> _logout() async {
    await clearToken();
    await UserService.instance.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Logged out')));
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 800;

          final settingsList = ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey.shade50,
                    child: const Icon(Icons.person, color: Colors.black54),
                  ),
                  title: Text(_user?['name']?.toString() ?? 'Guest user'),
                  subtitle: Text(
                    _loadingUser
                        ? 'Loading profile...'
                        : _user?['email']?.toString() ?? 'Tap to sign in',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      if (_user == null) {
                        if (!mounted) return;
                        Navigator.pushNamed(context, '/login');
                        return;
                      }
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileSettingPage(),
                        ),
                      );
                      if (result == true) {
                        _loadUser();
                      }
                    },
                  ),
                ),
              ),
              _settingTile(Icons.lock_outline, 'Change Password', onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change Password tapped')),
                );
              }),
              const Divider(height: 32),

              const Text('Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('App Notifications'),
                value: _notifications,
                activeThumbColor: Colors.blue,
                onChanged: (v) {
                  setState(() => _notifications = v);
                  _savePref('pref_notifications', v);
                },
                secondary: const Icon(Icons.notifications_outlined),
              ),
              SwitchListTile(
                title: const Text('Newsletter Subscription'),
                value: _newsletter,
                activeThumbColor: Colors.blue,
                onChanged: (v) {
                  setState(() => _newsletter = v);
                  _savePref('pref_newsletter', v);
                },
                secondary: const Icon(Icons.email_outlined),
              ),
              const Divider(height: 32),

              const Text('Appearance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: _darkMode,
                activeThumbColor: Colors.blue,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  _savePref('pref_dark_mode', v);
                },
                secondary: const Icon(Icons.dark_mode_outlined),
              ),
              const Divider(height: 32),

              const Text('About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _settingTile(Icons.info_outline, 'App Version: 1.0.0'),
              _settingTile(Icons.policy_outlined, 'Privacy Policy', onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy tapped')),
                );
              }),
              _settingTile(Icons.description_outlined, 'Terms & Conditions',
                  onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terms & Conditions tapped')),
                );
              }),
              const SizedBox(height: 40),
              if (_user != null)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _logout,
                  ),
                )
              else
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: settingsList,
                ),
              ),
            );
          }
          return SafeArea(child: settingsList);
        },
      ),
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
