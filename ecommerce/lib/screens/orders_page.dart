// lib/screens/orders_page.dart
import 'package:flutter/material.dart';

// Make sure this path matches your project structure:
import 'package:ecommerce/screens/home_screen.dart';
import 'package:ecommerce/services/order_service.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          leading: Builder(
            builder: (ctx) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              );
            },
          ),
        ),
        body: const OrdersView(),
      ),
    );
  }
}

/// Responsive orders view with mock data
class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  List<OrderSummary> _orders = [];
  bool _loading = true;
  String? _error;

  String _search = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await OrderService.instance.fetchOrders();
      setState(() {
        _orders = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
        _orders = [];
      });
    }
  }

  List<OrderSummary> get _filteredOrders {
    return _orders.where((o) {
      final matchesStatus =
          _filterStatus == 'All' ||
          o.status.toLowerCase() == _filterStatus.toLowerCase();
      final matchesSearch =
          _search.isEmpty ||
          o.id.toLowerCase().contains(_search.toLowerCase()) ||
          o.items.any(
            (it) => it.name.toLowerCase().contains(_search.toLowerCase()),
          );
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Failed to load orders',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= 900;
        final statusOptions = <String>{};
        for (final o in _orders) {
          statusOptions.add(_normalizeStatus(o.status));
        }
        final statuses = ['All', ...statusOptions];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Controls
              Row(
                children: [
                  // Search
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by order id or product',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status filter
                  DropdownButton<String>(
                    value: _filterStatus,
                    items: statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _filterStatus = v ?? 'All'),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _loadOrders,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Main area
              Expanded(
                child: _filteredOrders.isEmpty
                    ? const Center(child: Text('No orders match your search.'))
                    : isWide
                    ? _buildTableView(context, _filteredOrders)
                    : _buildListView(context, _filteredOrders),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableView(BuildContext context, List<OrderSummary> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: DataTable(
          columnSpacing: 24,
          showBottomBorder: true,
          columns: const [
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Items')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: data.map((o) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    o.id,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(_formatDate(o.createdAt))),
                DataCell(Text('${o.items.length}')),
                DataCell(Text('₹${o.amount.toStringAsFixed(2)}')),
                DataCell(_statusChip(o.status)),
                DataCell(
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _showOrderDetails(context, o),
                        child: const Text('View'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _reorder(context, o),
                        child: const Text('Reorder'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<OrderSummary> data) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final o = data[idx];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    o.id,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '₹${o.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Text(_formatDate(o.createdAt)),
                  const SizedBox(width: 12),
                  _statusChip(o.status),
                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...o.items.map(
                      (it) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${it.name} x${it.qty}')),
                            Text('₹${(it.price * it.qty).toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery to',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatAddress(o),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _showOrderDetails(context, o),
                          child: const Text('View details'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => _reorder(context, o),
                          child: const Text('Reorder'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderDetails(BuildContext context, OrderSummary o) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order ${o.id}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${_formatDate(o.createdAt)}'),
                const SizedBox(height: 8),
                Text('Status: ${o.status}'),
                const SizedBox(height: 12),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                ...o.items.map(
                  (it) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${it.name} x${it.qty}')),
                        Text('₹${(it.price * it.qty).toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total: ₹${o.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text('Payment: ${_normalizeStatus(o.paymentMethod)}'),
                const SizedBox(height: 8),
                const Text(
                  'Shipping address:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAddress(o, multiline: true),
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _reorder(context, o);
              },
              child: const Text('Reorder'),
            ),
          ],
        );
      },
    );
  }

  void _reorder(BuildContext context, OrderSummary o) {
    // Dummy action: show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reorder placed for ${o.id} (mock)')),
    );
  }

  static Widget _statusChip(String status) {
    Color bg;
    Color text;
    final normalized = status.toLowerCase().replaceAll('_', ' ');
    switch (normalized) {
      case 'pending':
      case 'pending payment':
        bg = Colors.orange.shade100;
        text = Colors.orange.shade800;
        break;
      case 'processing':
        bg = Colors.blue.shade100;
        text = Colors.blue.shade800;
        break;
      case 'shipped':
        bg = Colors.purple.shade100;
        text = Colors.purple.shade800;
        break;
      case 'delivered':
      case 'paid':
        bg = Colors.green.shade100;
        text = Colors.green.shade800;
        break;
      case 'cancelled':
        bg = Colors.red.shade100;
        text = Colors.red.shade800;
        break;
      case 'failed':
        bg = Colors.redAccent.shade100;
        text = Colors.redAccent.shade700;
        break;
      case 'created':
        bg = Colors.blueGrey.shade100;
        text = Colors.blueGrey.shade800;
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _normalizeStatus(status),
        style: TextStyle(fontSize: 12, color: text, fontWeight: FontWeight.w600),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }
}

String _normalizeStatus(String status) {
  if (status.isEmpty) return status;
  final parts = status.split(RegExp(r'[_\s-]+'));
  return parts
      .map((s) {
        if (s.isEmpty) return s;
        return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
      })
      .join(' ');
}

String _formatAddress(OrderSummary order, {bool multiline = false}) {
  final addr = order.shippingAddress;
  if (addr == null || addr.isEmpty) {
    return order.receipt ?? 'Not provided';
  }
  final segments = <String>[
    addr.fullName,
    addr.line1,
    if (addr.line2.isNotEmpty) addr.line2,
    [addr.city, addr.state].where((e) => e.isNotEmpty).join(', '),
    addr.postalCode,
    if (addr.phone.isNotEmpty) 'Phone: ${addr.phone}',
  ].where((element) => element.isNotEmpty).toList();
  return multiline ? segments.join('\n') : segments.join(', ');
}
