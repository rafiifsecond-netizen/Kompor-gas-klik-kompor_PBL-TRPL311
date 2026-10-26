import 'package:flutter_test/flutter_test.dart';
import 'package:klikkompor_mobile/repositories/address_repository.dart';
import 'package:klikkompor_mobile/repositories/chat_repository.dart';
import 'package:klikkompor_mobile/repositories/order_repository.dart';

void main() {
  test('dummy technician chats are available', () async {
    final response = await ChatRepository().getTechnicianChats();
    final data = response['data'] as List;
    expect(data, isNotEmpty);
    expect(data.length, greaterThanOrEqualTo(4));
  });

  test('dummy additional costs persist after adding', () async {
    final repository = OrderRepository();
    final marker = 'Test part ${DateTime.now().microsecondsSinceEpoch}';
    await repository.addAdditionalCost(1, {
      'item_name': marker,
      'quantity': 1,
      'subtotal': 12345,
      'status': 'pending',
    });

    final response = await repository.getAdditionalCosts(1);
    final costs = response['data'] as List;
    expect(costs.any((item) => item['item_name'] == marker), isTrue);
  });

  test('dummy default address leaves exactly one primary address', () async {
    final repository = AddressRepository();
    await repository.setDefaultDummy(2);
    final addresses = await repository.getAddresses();
    expect(addresses.where((item) => item['is_default'] == true), hasLength(1));
    expect(
        addresses.firstWhere((item) => item['id'] == 2)['is_default'], isTrue);
  });

  test('dummy sent chat message is available after reload', () async {
    final repository = ChatRepository();
    const message = 'Pesan uji tersimpan';
    await repository.sendMessage(1, message);
    final response = await repository.getOrderChat(1);
    final messages = response['data']['messages'] as List;
    expect(messages.any((item) => item['message'] == message), isTrue);
  });
}
