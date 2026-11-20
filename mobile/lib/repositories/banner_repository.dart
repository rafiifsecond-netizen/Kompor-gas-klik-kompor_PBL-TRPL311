import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/banner_model.dart';

class BannerRepository {
  final ApiClient _api;

  BannerRepository({ApiClient? api}) : _api = api ?? ApiClient();

  /// Fetches active banners from backend API for dashboard carousel.
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _api.get(ApiEndpoints.banners);
      final rows = response is Map ? response['data'] : null;

      if (rows is List) {
        return rows
            .whereType<Map>()
            .map((m) => BannerModel.fromJson(Map<String, dynamic>.from(m)))
            .where((b) => b.isActive)
            .toList();
      }
    } catch (_) {
      // Graceful fallback on network error or offline
    }
    return [];
  }
}
