import 'dart:convert';
import '../../../../core/network/api_client.dart';

class PaymentRepository {
  final ApiClient _client;
  PaymentRepository(this._client);

  Future<void> confirm({
    required String paymentKey,
    required String orderId,
    required int amount,
    required int lectureId,
  }) async {
    final response = await _client.post('/payments/confirm', body: {
      'paymentKey': paymentKey,
      'orderId': orderId,
      'amount': amount,
      'lectureId': lectureId,
    });
    if (response.statusCode != 200) {
      final msg = jsonDecode(response.body)['message'] ?? '결제 승인 실패';
      throw Exception(msg);
    }
  }
}
