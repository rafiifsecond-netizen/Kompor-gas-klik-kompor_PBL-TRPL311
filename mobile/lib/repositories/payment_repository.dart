import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';

class PaymentRepository {
  final ApiClient _api;
  PaymentRepository({ApiClient? api}) : _api = api ?? ApiClient();

  /// Validasi Kupon Promo
  Future<dynamic> validatePromo({
    required int orderId,
    required String promoCode,
    required String paymentMethod,
  }) async {
    return _api.post(ApiEndpoints.validatePromo, data: {
      'order_id': orderId,
      'promo_code': promoCode.trim().toUpperCase(),
      'payment_method': paymentMethod,
    });
  }

  /// Checkout Pembayaran (QRIS, Transfer Manual, atau Cash)
  Future<dynamic> checkout({
    required int orderId,
    required String paymentMethod,
    String? promoCode,
    String? idempotencyKey,
    String? senderBankName,
    String? senderAccountName,
  }) async {
    return _api.post(
      ApiEndpoints.paymentCheckout,
      data: {
        'order_id': orderId,
        'payment_method': paymentMethod,
        if (promoCode != null && promoCode.trim().isNotEmpty)
          'promo_code': promoCode.trim().toUpperCase(),
        if (senderBankName != null && senderBankName.isNotEmpty)
          'sender_bank_name': senderBankName,
        if (senderAccountName != null && senderAccountName.isNotEmpty)
          'sender_account_name': senderAccountName,
      },
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );
  }

  /// Polling Status Pembayaran Real-time
  Future<dynamic> getPaymentStatus(int paymentId) async {
    return _api.get(ApiEndpoints.paymentStatus(paymentId));
  }

  /// Upload Bukti Transfer Manual
  Future<dynamic> uploadProof({
    required int paymentId,
    required XFile proofFile,
    String? senderBankName,
    String? senderAccountName,
  }) async {
    final bytes = await proofFile.readAsBytes();
    final fileName = proofFile.name.isNotEmpty ? proofFile.name : 'bukti_transfer.jpg';

    final formData = FormData.fromMap({
      'proof': MultipartFile.fromBytes(bytes, filename: fileName),
      if (senderBankName != null && senderBankName.isNotEmpty)
        'sender_bank_name': senderBankName,
      if (senderAccountName != null && senderAccountName.isNotEmpty)
        'sender_account_name': senderAccountName,
    });

    return _api.post(
      ApiEndpoints.uploadPaymentProof(paymentId),
      data: formData,
    );
  }

  /// Teknisi Konfirmasi Pembayaran Tunai (Cash)
  Future<dynamic> confirmCashPayment({
    required int paymentId,
    required int amountReceived,
  }) async {
    return _api.post(
      ApiEndpoints.confirmCashPayment(paymentId),
      data: {'amount_received': amountReceived},
    );
  }

  /// Ambil Info Dompet Teknisi
  Future<dynamic> getTechnicianWallet() async {
    return _api.get(ApiEndpoints.technicianWallet);
  }

  /// Pengajuan Penarikan Saldo Teknisi (Payout)
  Future<dynamic> requestPayout({
    required int amount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  }) async {
    return _api.post(
      ApiEndpoints.requestPayout,
      data: {
        'amount': amount,
        'bank_name': bankName,
        'bank_account_number': accountNumber,
        'bank_account_holder': accountHolder,
      },
    );
  }
}
