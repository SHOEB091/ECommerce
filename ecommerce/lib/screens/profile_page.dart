import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'profile_setting_page.dart'; // ✅ Edit Profile page
import 'address_screen.dart'; // ✅ Address Manager
import 'package:ecommerce/screens/home_screen.dart';
import '../services/user_service.dart';
import '../utils/api.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  bool get _isLoggedIn => _user != null;

  String get _userName {
    final name = _user?['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    return _isLoggedIn ? 'User' : 'Guest';
  }

  String get _userEmail => _user?['email']?.toString() ?? '';

  String? get _userRole => _user?['role']?.toString();

  String get _profileImage {
    final avatar = _user?['avatar']?.toString();
    if (avatar != null && avatar.isNotEmpty) return avatar;
    final email = _userEmail;
    if (email.isNotEmpty) {
      final hash = email.hashCode.abs();
      return "https://i.pravatar.cc/150?img=${hash % 70}";
    }
    return "";
  }

  List<Map<String, dynamic>> _addresses = [];
  int _voucherCount = 0;
  double _appRating = 0.0;
  int? _userRating;
  bool _loadingAddresses = false;
  bool _loadingVouchers = false;
  bool _loadingRating = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔹 Load user data from secure storage (saved during login)
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = await UserService.instance.ensureUserLoaded();
      if (!mounted) return;
      setState(() {
        _user = user;
      });
      
      // Load dynamic data if user is logged in
      if (_isLoggedIn) {
        _loadAddresses();
        _loadVouchers();
        _loadRating();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Check if user is logged in
      final token = await _storage.read(key: 'auth_token');
      if (token == null) {
        // No token, user not logged in
        setState(() {
          _user = null;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Load addresses from API
  Future<void> _loadAddresses() async {
    if (!_isLoggedIn) return;
    setState(() => _loadingAddresses = true);
    try {
      final response = await get('/api/address');
      if (mounted && response['success'] == true) {
        setState(() {
          _addresses = List<Map<String, dynamic>>.from(response['addresses'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingAddresses = false);
      }
    }
  }

  // 🔹 Load vouchers from API
  Future<void> _loadVouchers() async {
    if (!_isLoggedIn) return;
    setState(() => _loadingVouchers = true);
    try {
      final response = await get('/api/v1/vouchers');
      if (mounted && response['success'] == true) {
        setState(() {
          _voucherCount = response['count'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading vouchers: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingVouchers = false);
      }
    }
  }

  // 🔹 Load rating from API
  Future<void> _loadRating() async {
    if (!_isLoggedIn) return;
    setState(() => _loadingRating = true);
    try {
      final response = await get('/api/v1/ratings');
      if (mounted && response['success'] == true) {
        setState(() {
          _appRating = (response['averageRating'] ?? 0.0).toDouble();
          _userRating = response['userRating']?['rating'];
        });
      }
    } catch (e) {
      debugPrint('Error loading rating: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingRating = false);
      }
    }
  }

  // 🔹 Get address display text
  String get _addressDisplay {
    if (_addresses.isEmpty) return 'No address added';
    final defaultAddress = _addresses.firstWhere(
      (addr) => addr['isDefault'] == true,
      orElse: () => _addresses.first,
    );
    final parts = <String>[];
    if (defaultAddress['name'] != null) parts.add(defaultAddress['name'].toString());
    if (defaultAddress['street'] != null) parts.add(defaultAddress['street'].toString());
    if (defaultAddress['city'] != null) parts.add(defaultAddress['city'].toString());
    return parts.isNotEmpty ? parts.join(', ') : 'Tap to add address';
  }

  // 🔹 Navigate to Edit Profile and refresh when back
  Future<void> _onEditProfile() async {
    if (!_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSettingPage()),
    );

    // Refresh profile data after returning
    _loadUserData();
  }

  void _onAddressTap() {
    if (!_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressManager()),
    ).then((_) {
      // Refresh addresses when returning
      _loadAddresses();
    });
  }

  void _onVoucherTap() {
    if (!_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Vouchers'),
        content: Text(
          _voucherCount > 0
              ? 'You have $_voucherCount active voucher${_voucherCount > 1 ? 's' : ''} available!'
              : 'You don\'t have any active vouchers at the moment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onRateAppTap() async {
    if (!_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    int? selectedRating = _userRating;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Rate this app'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final rating = index + 1;
                  return IconButton(
                    icon: Icon(
                      rating <= (selectedRating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        selectedRating = rating;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                selectedRating != null
                    ? 'You rated: $selectedRating stars'
                    : 'Tap stars to rate',
                style: const TextStyle(fontSize: 14),
              ),
              if (_appRating > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'Average rating: ${_appRating.toStringAsFixed(1)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (selectedRating != null)
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _submitRating(selectedRating!);
                },
                child: const Text('Submit'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating(int rating) async {
    try {
      final response = await post('/api/v1/ratings', {'rating': rating});
      if (mounted && response['success'] == true) {
        setState(() {
          _appRating = (response['averageRating'] ?? 0.0).toDouble();
          _userRating = response['userRating']?['rating'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thank you for rating!')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit rating')),
        );
      }
    }
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
      await UserService.instance.clear();
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
    final bool isLoggedIn = _isLoggedIn;
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
                          backgroundImage:
                              _profileImage.isNotEmpty ? NetworkImage(_profileImage) : null,
                          child: _profileImage.isEmpty
                              ? Text(
                                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
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
                                _userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isLoggedIn ? _userEmail : 'Please log in to view details',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (_userRole != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _userRole == 'admin' || _userRole == 'superadmin'
                                        ? Colors.orange.shade100
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _userRole!.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _userRole == 'admin' || _userRole == 'superadmin'
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
              subtitle: _loadingAddresses ? 'Loading...' : _addressDisplay,
            ),
            _OptionItem(
              Icons.card_giftcard,
              'Voucher',
              _onVoucherTap,
              subtitle: _loadingVouchers
                  ? 'Loading...'
                  : _voucherCount > 0
                      ? '$_voucherCount available'
                      : 'No vouchers',
            ),
            _OptionItem(
              Icons.star_border,
              'Rate this app',
              _onRateAppTap,
              subtitle: _loadingRating
                  ? 'Loading...'
                  : _userRating != null
                      ? 'Your rating: $_userRating/5 • Avg: ${_appRating.toStringAsFixed(1)}'
                      : _appRating > 0
                          ? 'Average: ${_appRating.toStringAsFixed(1)}/5'
                          : 'Tap to rate',
            ),
            if (isLoggedIn)
              _OptionItem(Icons.logout, 'Log out', _onLogout, color: Colors.redAccent)
            else
              _OptionItem(Icons.login, 'Sign In', () => Navigator.pushNamed(context, '/login'),
                  color: Colors.blueAccent),
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
