import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  Map<String, dynamic>? _statsResponse;
  List<Map<String, dynamic>> _users = const [];
  List<Map<String, dynamic>> _orders = const [];
  bool _loading = true;
  String? _error;
  String? _updatingOrderId;

  final _currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  static const _statuses = [
    'created',
    'pending_payment',
    'paid',
    'failed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        AdminService.instance.fetchStats(),
        AdminService.instance.fetchUsers(),
        AdminService.instance.fetchOrders(),
      ]);
      if (!mounted) return;
      setState(() {
        _statsResponse = results[0] as Map<String, dynamic>;
        _users = List<Map<String, dynamic>>.from(results[1] as List);
        _orders = List<Map<String, dynamic>>.from(results[2] as List);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    setState(() => _updatingOrderId = orderId);
    try {
      final updated = await AdminService.instance.updateOrderStatus(orderId, status);
      if (!mounted) return;
      setState(() {
        _orders = _orders
            .map((order) => order['_id'] == orderId ? updated : order)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order updated to ${status.toUpperCase()}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $e')),
      );
    } finally {
      if (mounted) setState(() => _updatingOrderId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(),
                        const SizedBox(height: 24),
                        _buildOrdersSection(),
                        const SizedBox(height: 24),
                        _buildUsersSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _statsResponse?['stats'] as Map<String, dynamic>? ?? {};
    final revenue = stats['revenue'] is num ? stats['revenue'] as num : 0;

    final cards = [
      _StatCard(
        label: 'Total Users',
        value: '${stats['totalUsers'] ?? 0}',
        icon: Icons.people_alt,
        color: Colors.indigo,
      ),
      _StatCard(
        label: 'Total Orders',
        value: '${stats['totalOrders'] ?? 0}',
        icon: Icons.shopping_bag,
        color: Colors.deepPurple,
      ),
      _StatCard(
        label: 'Paid Orders',
        value: '${stats['paidOrders'] ?? 0}',
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      _StatCard(
        label: 'Pending',
        value: '${stats['pendingOrders'] ?? 0}',
        icon: Icons.pending_actions,
        color: Colors.orange,
      ),
      _StatCard(
        label: 'Cancelled',
        value: '${stats['cancelledOrders'] ?? 0}',
        icon: Icons.cancel,
        color: Colors.red,
      ),
      _StatCard(
        label: 'Failed',
        value: '${stats['failedOrders'] ?? 0}',
        icon: Icons.error_outline,
        color: Colors.redAccent,
      ),
      _StatCard(
        label: 'Revenue',
        value: _currencyFormatter.format(revenue),
        icon: Icons.currency_rupee,
        color: Colors.blueGrey,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards,
    );
  }

  Widget _buildOrdersSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_orders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No orders found'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return _orderTile(order);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _orderTile(Map<String, dynamic> order) {
    final id = order['_id']?.toString() ?? '';
    final status = order['status']?.toString() ?? 'created';
    final amount = order['amount'] is num ? order['amount'] as num : 0;
    
    // Get user details from populated userId or user field
    final customer = order['userId'] ?? order['user'];
    final customerName = customer is Map<String, dynamic>
        ? customer['name']?.toString() ?? 'Unknown user'
        : 'Guest checkout';
    final customerEmail = customer is Map<String, dynamic>
        ? customer['email']?.toString() ?? ''
        : '';
    
    final createdAt = order['createdAt']?.toString();
    final createdLabel = createdAt != null
        ? DateFormat.yMMMd().add_jm().format(DateTime.parse(createdAt))
        : '';

    // Color code based on status
    Color statusColor = Colors.grey;
    if (status == 'paid') statusColor = Colors.green;
    else if (status == 'cancelled') statusColor = Colors.red;
    else if (status == 'failed') statusColor = Colors.redAccent;
    else if (['created', 'pending_payment'].contains(status)) statusColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            status == 'paid' ? Icons.check_circle :
            status == 'cancelled' ? Icons.cancel :
            status == 'failed' ? Icons.error :
            Icons.pending,
            color: statusColor,
          ),
        ),
        title: Text(
          customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customerEmail.isNotEmpty) Text('Email: $customerEmail', style: const TextStyle(fontSize: 12)),
            Text('Order #${id.substring(0, id.length > 8 ? 8 : id.length)}...'),
            Text('Created: $createdLabel', style: const TextStyle(fontSize: 11)),
            Text(
              'Amount: ${_currencyFormatter.format(amount)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: status,
            items: _statuses
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.replaceAll('_', ' ').toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null && value != status) {
                _updateOrderStatus(id, value);
              }
            },
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_users.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No users found'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueGrey.shade50,
                      child: Text(
                        (user['name']?.toString().isNotEmpty ?? false)
                            ? user['name'].toString()[0].toUpperCase()
                            : 'U',
                      ),
                    ),
                    title: Text(user['name']?.toString() ?? 'Unnamed User'),
                    subtitle: Text(user['email']?.toString() ?? ''),
                    trailing: Text(
                      user['role']?.toString().toUpperCase() ?? 'USER',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

