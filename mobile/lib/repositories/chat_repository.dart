import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class ChatRepository {
  final ApiClient _api;
  ChatRepository({ApiClient? api}) : _api = api ?? ApiClient();
  Future<dynamic> getOrderChat(int id) async {
    return _api.get(ApiEndpoints.orderChat(id));
  }

  Future<dynamic> sendMessage(int id, String message) async {
    return _api
        .post(ApiEndpoints.sendChatMessage(id), data: {'message': message});
  }

  Future<dynamic> getTechnicianChats() async {
    return _api.get(ApiEndpoints.technicianChats);
  }
}
