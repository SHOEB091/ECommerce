// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'profile_setting_page.dart';
import 'package:ecommerce/screens/home_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Back button that always goes to HomeScreen (clears stack)
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
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 800;

        // Common profile header
        Widget profileHeader = Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Sunie Pham', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 6),
                      Text('sunieux@gmail.com', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black87),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSettingPage()));
                  },
                ),
              ],
            ),
          ),
        );

        // Options list
        final options = <_OptionItem>[
          _OptionItem(Icons.location_on_outlined, 'Address', () {}),
          _OptionItem(Icons.credit_card, 'Payment method', () {}),
          _OptionItem(Icons.card_giftcard, 'Voucher', () {}),
          _OptionItem(Icons.favorite_border, 'My Wishlist', () {}),
          _OptionItem(Icons.star_border, 'Rate this app', () {}),
          _OptionItem(Icons.logout, 'Log out', () {}, color: Colors.redAccent),
        ];

        Widget optionsList = ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final it = options[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0.6,
              child: ListTile(
                leading: Icon(it.icon, color: it.color ?? Colors.grey.shade700),
                title: Text(it.title, style: const TextStyle(fontSize: 15)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: it.onTap,
              ),
            );
          },
        );

        if (isDesktop) {
          // Desktop: two columns with some spacing and a centered container
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: profile header + quick stats (width 360)
                    SizedBox(
                      width: 360,
                      child: Column(
                        children: [
                          profileHeader,
                          const SizedBox(height: 18),
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0.8,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit profile'),
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.history),
                                    label: const Text('Order history'),
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 28),

                    // Right column: options list (expanded)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Account settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          Expanded(child: optionsList),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Mobile: single column
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  profileHeader,
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Account settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: optionsList),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}

class _OptionItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const _OptionItem(this.icon, this.title, this.onTap, {this.color});
}
