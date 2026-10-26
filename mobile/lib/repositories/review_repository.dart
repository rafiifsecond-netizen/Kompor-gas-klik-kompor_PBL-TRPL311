import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../data/dummy/dummy_data.dart';

class ReviewRepository {
  final ApiClient _api;
  ReviewRepository({ApiClient? api}) : _api = api ?? ApiClient();
  static final _memory = [...dummyReviews];

  Future<List<Map<String, dynamic>>> getReviews(int technicianId) async {
    if (AppConfig.useDummyData) return List<Map<String, dynamic>>.from(_memory);
    final response = await _api.get('/technicians/$technicianId/reviews');
    final rows = response is Map ? response['data'] : null;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }

  Future<void> createReview(
      {required int rating, required String comment}) async {
    if (AppConfig.useDummyData) {
      _memory.add({
        'id': _memory.length + 1,
        'customer': 'Anda',
        'rating': rating,
        'comment': comment
      });
      return;
    }
    await _api.post('/reviews', data: {'rating': rating, 'comment': comment});
  }
}
