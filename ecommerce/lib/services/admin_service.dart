import '../utils/api.dart';

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  Future<Map<String, dynamic>> fetchStats() async {
    final resp = await get('/admin/stats', auth: true);
    final status = resp['status'] as int?;
    final body = resp['body'] as Map<String, dynamic>?;
    if (status == 200 && body != null && body['success'] == true) {
      return body;
    }
    throw Exception(body?['message'] ?? 'Failed to load stats');
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final resp = await get('/admin/users', auth: true);
    final status = resp['status'] as int?;
    final body = resp['body'] as Map<String, dynamic>?;
    if (status == 200 && body != null && body['success'] == true && body['users'] is List) {
      return List<Map<String, dynamic>>.from(body['users'] as List);
    }
    throw Exception(body?['message'] ?? 'Failed to load users');
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final resp = await get('/admin/orders', auth: true);
    final status = resp['status'] as int?;
    final body = resp['body'] as Map<String, dynamic>?;
    if (status == 200 && body != null && body['success'] == true && body['orders'] is List) {
      return List<Map<String, dynamic>>.from(body['orders'] as List);
    }
    throw Exception(body?['message'] ?? 'Failed to load orders');
  }

  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    final resp = await patch('/admin/orders/$orderId', {'status': status}, auth: true);
    final statusCode = resp['status'] as int?;
    final body = resp['body'] as Map<String, dynamic>?;
    if (statusCode == 200 && body != null && body['success'] == true && body['order'] != null) {
      return Map<String, dynamic>.from(body['order'] as Map);
    }
    throw Exception(body?['message'] ?? 'Failed to update order');
  }
}

