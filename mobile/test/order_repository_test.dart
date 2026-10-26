import 'package:flutter_test/flutter_test.dart';
import 'package:klikkompor_mobile/repositories/order_repository.dart';

void main() {
  test('dummy updateStatus is visible through getOrder', () async {
    final repository = OrderRepository();
    await repository.updateStatus(1, {'status': 'completed'});
    final response = await repository.getOrder(1);
    final data = response['data'] as Map<String, dynamic>;
    expect(data['status'], 'completed');
  });
}
