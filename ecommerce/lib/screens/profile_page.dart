import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'profile_setting_page.dart'; // ✅ Edit Profile page
import 'address_screen.dart'; // ✅ Address Manager
import 'package:ecommerce/screens/home_screen.dart';
import '../utils/api.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  
  // User data loaded from login credentials
  String userName = "Loading...";
  String userEmail = "";
  String profileImage = "https://i.pravatar.cc/150?img=47";
  String? userId;
  String? userRole;

  final List<String> _addressLines = ['Home', '12/4 MG Road, New Delhi, 110001'];
  final String _paymentMethod = 'Visa •••• 4242';
  final int _voucherCount = 2;
  final int _wishlistCount = 7;
  final double _appRating = 4.6;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔹 Load user data from secure storage (saved during login)
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      // First, try to load from secure storage (saved during login)
      final userJson = await _storage.read(key: 'user');
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        setState(() {
          userName = userData['name']?.toString() ?? 'User';
          userEmail = userData['email']?.toString() ?? '';
          userId = userData['id']?.toString() ?? userData['_id']?.toString();
          userRole = userData['role']?.toString();
          // Generate profile image based on user name/email
          if (userEmail.isNotEmpty) {
            final hash = userEmail.hashCode.abs();
            profileImage = "https://i.pravatar.cc/150?img=${hash % 70}";
          }
        });
      }

      // Optionally fetch fresh data from backend
      try {
        final result = await get('/auth/me', auth: true);
        if (result['status'] == 200 && result['body'] != null) {
          final body = result['body'] as Map<String, dynamic>;
          if (body['success'] == true && body['user'] != null) {
            final userData = body['user'] as Map<String, dynamic>;
            setState(() {
              userName = userData['name']?.toString() ?? userName;
              userEmail = userData['email']?.toString() ?? userEmail;
              userId = userData['_id']?.toString() ?? userData['id']?.toString() ?? userId;
              userRole = userData['role']?.toString() ?? userRole;
              // Save updated user data
              _storage.write(key: 'user', value: jsonEncode(userData));
            });
          }
        }
      } catch (e) {
        debugPrint('Failed to fetch fresh user data: $e');
        // Continue with stored data if API call fails
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Check if user is logged in
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        // No token, user not logged in
        setState(() {
          userName = "Not logged in";
          userEmail = "Please log in to view profile";
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Navigate to Edit Profile and refresh when back
  Future<void> _onEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSettingPage()),
    );

    // Refresh profile data after returning
    _loadUserData();
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

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear all stored authentication data
      await clearToken();
      await _storage.delete(key: 'user');
      await _storage.delete(key: 'role');
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Refresh profile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
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
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(profileImage),
                          onBackgroundImageError: (_, __) {
                            // Fallback if image fails to load
                          },
                          child: profileImage.isEmpty
                              ? Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 6),
                              Text(userEmail, style: const TextStyle(color: Colors.grey)),
                              if (userRole != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: userRole == 'admin' || userRole == 'superadmin'
                                        ? Colors.orange.shade100
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    userRole!.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: userRole == 'admin' || userRole == 'superadmin'
                                          ? Colors.orange.shade800
                                          : Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
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
