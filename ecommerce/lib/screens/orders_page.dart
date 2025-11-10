// lib/screens/orders_page.dart
import 'package:flutter/material.dart';
import 'dart:math';

// Make sure this path matches your project structure:
import 'package:ecommerce/screens/home_screen.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to HomeScreen and clear previous routes so home is shown
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        return false; // we handled navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          leading: Builder(builder: (ctx) {
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
          }),
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
  // Mock orders data
  final List<Order> _orders = List.generate(8, (i) {
    final rnd = Random(i);
    final items = List.generate(1 + rnd.nextInt(3), (j) {
      return OrderItem(
        name: 'Product ${(i + 1) * (j + 1)}',
        qty: 1 + rnd.nextInt(3),
        price: (10 + rnd.nextInt(90)).toDouble(),
      );
    });
    final total = items.fold<double>(0, (t, it) => t + it.qty * it.price);
    final statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
    return Order(
      id: 'ORD-${1000 + i}',
      date: DateTime.now().subtract(Duration(days: rnd.nextInt(14))),
      status: statuses[rnd.nextInt(statuses.length)],
      items: items,
      total: total,
      address: '123, Example St, City ${i + 1}',
      paymentMethod: rnd.nextBool() ? 'Card' : 'UPI',
    );
  });

  String _search = '';
  String _filterStatus = 'All';

  List<Order> get _filteredOrders {
    return _orders.where((o) {
      final matchesStatus = _filterStatus == 'All' || o.status == _filterStatus;
      final matchesSearch = _search.isEmpty ||
          o.id.toLowerCase().contains(_search.toLowerCase()) ||
          o.items.any((it) => it.name.toLowerCase().contains(_search.toLowerCase()));
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isWide = width >= 900;

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
                  items: ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _filterStatus = v ?? 'All'),
                )
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
    });
  }

  Widget _buildTableView(BuildContext context, List<Order> data) {
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
            return DataRow(cells: [
              DataCell(Text(o.id, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(_formatDate(o.date))),
              DataCell(Text('${o.items.length}')),
              DataCell(Text('\$${o.total.toStringAsFixed(2)}')),
              DataCell(_statusChip(o.status)),
              DataCell(Row(
                children: [
                  TextButton(onPressed: () => _showOrderDetails(context, o), child: const Text('View')),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: () => _reorder(context, o), child: const Text('Reorder')),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<Order> data) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final o = data[idx];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Row(
              children: [
                Expanded(
                  child: Text(o.id, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text('\$${o.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Text(_formatDate(o.date)),
                  const SizedBox(width: 12),
                  _statusChip(o.status),
                ],
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Items:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...o.items.map((it) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${it.name} x${it.qty}')),
                              Text('\$${(it.price * it.qty).toStringAsFixed(2)}'),
                            ],
                          ),
                        )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery to', style: TextStyle(color: Colors.grey[700])),
                        Text(o.address),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(onPressed: () => _showOrderDetails(context, o), child: const Text('View details')),
                        const SizedBox(width: 12),
                        OutlinedButton(onPressed: () => _reorder(context, o), child: const Text('Reorder')),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showOrderDetails(BuildContext context, Order o) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order ${o.id}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${_formatDate(o.date)}'),
                const SizedBox(height: 8),
                Text('Status: ${o.status}'),
                const SizedBox(height: 12),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.w600)),
                ...o.items.map((it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${it.name} x${it.qty}')),
                          Text('\$${(it.price * it.qty).toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                Text('Total: \$${o.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text('Payment: ${o.paymentMethod}'),
                const SizedBox(height: 8),
                Text('Address: ${o.address}'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton(onPressed: () { Navigator.pop(context); _reorder(context, o); }, child: const Text('Reorder')),
          ],
        );
      },
    );
  }

  void _reorder(BuildContext context, Order o) {
    // Dummy action: show snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reorder placed for ${o.id} (mock)')));
  }

  static Widget _statusChip(String status) {
    Color bg;
    Color text;
    switch (status.toLowerCase()) {
      case 'pending':
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
        bg = Colors.green.shade100;
        text = Colors.green.shade800;
        break;
      case 'cancelled':
        bg = Colors.red.shade100;
        text = Colors.red.shade800;
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade800;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Text(status, style: TextStyle(fontSize: 12, color: text)),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }
}

/// Simple model classes for the demo
class Order {
  final String id;
  final DateTime date;
  final String status;
  final List<OrderItem> items;
  final double total;
  final String address;
  final String paymentMethod;
  Order({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
    required this.address,
    required this.paymentMethod,
  });
}

class OrderItem {
  final String name;
  final int qty;
  final double price;
  OrderItem({required this.name, required this.qty, required this.price});
}
