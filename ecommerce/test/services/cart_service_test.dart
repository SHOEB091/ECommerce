import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/services/cart_service.dart';

void main() {
  group('CartService', () {
    test('should be a singleton', () {
      final instance1 = CartService.instance;
      final instance2 = CartService.instance;
      expect(instance1, equals(instance2));
    });

    // Add more tests based on CartService implementation
    // These would require mocking API calls
  });
}

