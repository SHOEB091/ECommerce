import 'package:flutter/material.dart';
import 'profile_setting_page.dart'; // ✅ Edit Profile page
import 'address_screen.dart'; // ✅ Address Manager
import 'package:ecommerce/screens/home_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Dummy data (replace with real API data later)
  String userName = "Sunie Pham";
  String userEmail = "sunieux@gmail.com";
  String profileImage = "https://i.pravatar.cc/150?img=47";

  final List<String> _addressLines = ['Home', '12/4 MG Road, New Delhi, 110001'];
  String _paymentMethod = 'Visa •••• 4242';
  int _voucherCount = 2;
  int _wishlistCount = 7;
  double _appRating = 4.6;

  // 🔹 Navigate to Edit Profile and refresh when back
  Future<void> _onEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSettingPage()),
    );

    // Optional: refresh profile data after returning
    setState(() {
      // fetch user data again here (API call if available)
    });
  }

  void _onAddressTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressManager()),
    );
  }

  void _onPaymentTap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment method'),
        content: Text(_paymentMethod),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _onVoucherTap() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('You have $_voucherCount vouchers')));
  }

  void _onWishlistTap() {
    _onEditProfile(); // wishlist → edit profile (same for now)
  }

  void _onRateAppTap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate this app'),
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text('$_appRating'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
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
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth >= 800;

          // 🔹 Profile header
          Widget profileHeader = Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 40, backgroundImage: NetworkImage(profileImage)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 6),
                        Text(userEmail, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black87),
                    onPressed: _onEditProfile, // ✅ opens edit profile
                  ),
                ],
              ),
            ),
          );

          // 🔹 Options list
          final options = <_OptionItem>[
            _OptionItem(
              Icons.location_on_outlined,
              'Address',
              _onAddressTap,
              subtitle: _addressLines.join('\n'),
            ),
            _OptionItem(Icons.credit_card, 'Payment method', _onPaymentTap,
                subtitle: _paymentMethod),
            _OptionItem(Icons.card_giftcard, 'Voucher', _onVoucherTap,
                subtitle: '$_voucherCount available'),
            _OptionItem(Icons.favorite_border, 'My Wishlist', _onWishlistTap,
                subtitle: '$_wishlistCount items'),
            _OptionItem(Icons.star_border, 'Rate this app', _onRateAppTap,
                subtitle: 'Current rating: $_appRating'),
            _OptionItem(Icons.logout, 'Log out', _onLogout, color: Colors.redAccent),
          ];

          Widget optionsList = ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final it = options[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0.6,
                child: ListTile(
                  leading: Icon(it.icon, color: it.color ?? Colors.grey.shade700),
                  title: Text(it.title, style: const TextStyle(fontSize: 15)),
                  subtitle: it.subtitle != null ? Text(it.subtitle!) : null,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: it.onTap,
                ),
              );
            },
          );

          // 🔹 Responsive UI
          if (isDesktop) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 360,
                        child: Column(
                          children: [
                            profileHeader,
                            const SizedBox(height: 18),
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0.8,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text('Quick Actions',
                                        style: TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: _onEditProfile, // ✅ Edit Profile
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Edit profile'),
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedButton.icon(
                                      onPressed: _onAddressTap,
                                      icon: const Icon(Icons.location_on_outlined),
                                      label: const Text('Manage Address'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Account settings',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800)),
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
                      child: Text('Account settings',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: optionsList),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _OptionItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final String? subtitle;

  const _OptionItem(this.icon, this.title, this.onTap, {this.color, this.subtitle});
}
