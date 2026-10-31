import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class ReviewRepository {
  final ApiClient _api;
  ReviewRepository({ApiClient? api}) : _api = api ?? ApiClient();
  Future<List<Map<String, dynamic>>> getReviews(int technicianId) async {
    final response = await _api.get(
      ApiEndpoints.technicianDetail(technicianId),
    );
    final technician = response is Map ? response['data'] : null;
    final rows = technician is Map ? technician['reviews_received'] : null;
    return rows is List
        ? rows.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : [];
  }

  Future<void> createReview({
    required int orderId,
    required int rating,
    required String comment,
  }) async {
    await _api.post(
      ApiEndpoints.reviewOrder(orderId),
      data: {'rating': rating, 'comment': comment},
    );
  }
}
