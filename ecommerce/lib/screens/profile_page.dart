import 'package:flutter/material.dart';
import 'profile_setting_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Sunie Pham', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('sunieux@gmail.com', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black87),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSettingPage()));
                  },
                )
              ],
            ),
            const SizedBox(height: 25),
            _buildProfileOption(Icons.location_on_outlined, 'Address'),
            _buildProfileOption(Icons.credit_card, 'Payment method'),
            _buildProfileOption(Icons.card_giftcard, 'Voucher'),
            _buildProfileOption(Icons.favorite_border, 'My Wishlist'),
            _buildProfileOption(Icons.star_border, 'Rate this app'),
            _buildProfileOption(Icons.logout, 'Log out', color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {Color? color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0.8,
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.grey.shade700),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
