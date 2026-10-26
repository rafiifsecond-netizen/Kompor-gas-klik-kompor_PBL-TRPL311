import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/config/app_config.dart';
import '../data/dummy/dummy_data.dart';

class ChatRepository {
  final ApiClient _api;
  ChatRepository({ApiClient? api}) : _api = api ?? ApiClient();
  Future<dynamic> getOrderChat(int id) async {
    if (AppConfig.useDummyData) {
      return {
        'success': true,
        'data': {'messages': dummyChatMessages[id] ?? dummyChatMessages[1]!}
      };
    }
    return _api.get(ApiEndpoints.orderChat(id));
  }

  Future<dynamic> sendMessage(int id, String message) async {
    if (AppConfig.useDummyData) {
      final messages = dummyChatMessages.putIfAbsent(id, () => []);
      messages.add({
        'id': messages.length + 1,
        'message': message,
        'sender_type': 'customer',
        'created_at': DateTime.now().toIso8601String(),
      });
      _updateConversation(id, message);
      return {'success': true};
    }
    return _api
        .post(ApiEndpoints.sendChatMessage(id), data: {'message': message});
  }

  Future<dynamic> getTechnicianChats() async {
    if (AppConfig.useDummyData) {
      return {
        'success': true,
        'data': dummyTechnicianChats
            .map((chat) => Map<String, dynamic>.from(chat))
            .toList(),
      };
    }
    return _api.get(ApiEndpoints.technicianChats);
  }

  void _updateConversation(int orderId, String message) {
    final index =
        dummyTechnicianChats.indexWhere((chat) => chat['order_id'] == orderId);
    if (index == -1) return;
    final chat = dummyTechnicianChats[index];
    dummyTechnicianChats[index] = {
      ...chat,
      'last_message': message,
      'last_message_at': DateTime.now().toIso8601String(),
    };
  }
}
