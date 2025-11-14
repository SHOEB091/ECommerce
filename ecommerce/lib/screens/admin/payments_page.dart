import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/api.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  List<Map<String, dynamic>> _payments = [];
  bool _loading = true;
  String? _error;
  String _filterStatus = 'All';
  final _currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  final _statusOptions = ['All', 'created', 'pending_payment', 'paid', 'failed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await get('/payments/all', auth: true);
      final status = result['status'] as int?;
      final body = result['body'] as Map<String, dynamic>?;
      
      if (status == 200 && body != null && body['success'] == true) {
        final payments = body['payments'] as List? ?? [];
        setState(() {
          _payments = List<Map<String, dynamic>>.from(
            payments.map((p) => Map<String, dynamic>.from(p as Map)),
          );
        });
      } else {
        setState(() {
          _error = body?['message']?.toString() ?? 'Failed to load payments';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredPayments {
    if (_filterStatus == 'All') return _payments;
    return _payments.where((p) => p['status']?.toString() == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPayments,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPayments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('Filter by Status: '),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _filterStatus,
                              items: _statusOptions
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.replaceAll('_', ' ').toUpperCase()),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _filterStatus = v);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filteredPayments.isEmpty
                          ? const Center(child: Text('No payments found'))
                          : ListView.builder(
                              itemCount: _filteredPayments.length,
                              itemBuilder: (context, index) {
                                return _paymentCard(_filteredPayments[index]);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _paymentCard(Map<String, dynamic> payment) {
    final id = payment['_id']?.toString() ?? '';
    final status = payment['status']?.toString() ?? 'created';
    final amount = payment['amount'] is num ? payment['amount'] as num : 0;
    final user = payment['user'] ?? payment['userId'];
    final userName = user is Map ? user['name']?.toString() ?? 'Unknown' : 'Guest';
    final userEmail = user is Map ? user['email']?.toString() ?? '' : '';
    final createdAt = payment['createdAt']?.toString();
    final createdDate = createdAt != null
        ? DateFormat.yMMMd().add_jm().format(DateTime.parse(createdAt))
        : '';
    final razorpayOrderId = payment['razorpayOrderId']?.toString() ?? '';
    final razorpayPaymentId = payment['razorpayPaymentId']?.toString() ?? '';

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.pending;
    if (status == 'paid') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'cancelled') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else if (status == 'failed') {
      statusColor = Colors.redAccent;
      statusIcon = Icons.error;
    } else if (['created', 'pending_payment'].contains(status)) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userEmail.isNotEmpty) Text(userEmail, style: const TextStyle(fontSize: 12)),
            Text(
              _currencyFormatter.format(amount),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: statusColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Order ID', id),
                if (razorpayOrderId.isNotEmpty)
                  _detailRow('Razorpay Order', razorpayOrderId),
                if (razorpayPaymentId.isNotEmpty)
                  _detailRow('Payment ID', razorpayPaymentId),
                _detailRow('Date', createdDate),
                _detailRow('Status', status.replaceAll('_', ' ').toUpperCase()),
                _detailRow('Amount', _currencyFormatter.format(amount)),
                if (payment['items'] is List && (payment['items'] as List).isNotEmpty) ...[
                  const Divider(),
                  const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...(payment['items'] as List).map((item) {
                    final itemMap = Map<String, dynamic>.from(item as Map);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('${itemMap['name'] ?? 'Item'} x${itemMap['qty'] ?? 1}'),
                          ),
                          Text('₹${((itemMap['price'] ?? 0) * (itemMap['qty'] ?? 1)).toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

