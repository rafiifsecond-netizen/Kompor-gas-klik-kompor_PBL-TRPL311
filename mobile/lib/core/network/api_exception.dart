import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  /// Extracts the first validation error message for a given field
  String? getFieldError(String field) {
    if (errors == null || !errors!.containsKey(field)) return null;
    final val = errors![field];
    if (val is List && val.isNotEmpty) return val.first.toString();
    if (val is String) return val;
    return null;
  }

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Koneksi ke server terputus (timeout). Silakan periksa jaringan Anda.',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Gagal terhubung ke server backend KlikKompor. Pastikan API server aktif.',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null && response.data is Map) {
          final data = response.data as Map;
          final msg = data['message'] ?? 'Terjadi kesalahan pada server.';
          final errs = data['errors'] is Map ? Map<String, dynamic>.from(data['errors']) : null;
          return ApiException(
            message: msg.toString(),
            statusCode: response.statusCode,
            errors: errs,
          );
        }
        return ApiException(
          message: 'Server mengembalikan status error: ${response?.statusCode}',
          statusCode: response?.statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Permintaan dibatalkan.');
      default:
        return ApiException(
          message: error.message ?? 'Terjadi kesalahan tidak terduga.',
        );
    }
  }

  @override
  String toString() => message;
}
