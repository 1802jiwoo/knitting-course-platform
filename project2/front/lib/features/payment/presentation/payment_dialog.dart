import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../data/repositories/payment_repository_impl.dart';

class PaymentDialog extends StatefulWidget {
  final int lectureId;
  final String lectureTitle;
  final int price;
  final ApiClient apiClient;
  final VoidCallback onSuccess;

  const PaymentDialog({
    super.key,
    required this.lectureId,
    required this.lectureTitle,
    required this.price,
    required this.apiClient,
    required this.onSuccess,
  });

  static Future<bool> show({
    required BuildContext context,
    required int lectureId,
    required String lectureTitle,
    required int price,
    required ApiClient apiClient,
    required VoidCallback onSuccess,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentDialog(
        lectureId: lectureId,
        lectureTitle: lectureTitle,
        price: price,
        apiClient: apiClient,
        onSuccess: onSuccess,
      ),
    );
    return result ?? false;
  }

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool _isLoading = false;
  String? _error;

  Future<void> _onPay() async {
    setState(() { _isLoading = true; _error = null; });

    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}_${widget.lectureId}';
    final paymentKey = 'test_bypass_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final repo = PaymentRepository(widget.apiClient);
      await repo.confirm(
        paymentKey: paymentKey,
        orderId: orderId,
        amount: widget.price,
        lectureId: widget.lectureId,
      );
      if (mounted) {
        Navigator.pop(context, true);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString().replaceAll('Exception: ', ''); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3182F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('toss', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 8),
            const Text('결제하기', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ]),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Text(widget.lectureTitle, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('결제 금액', style: TextStyle(fontSize: 13, color: Colors.black54)),
              Text(
                '₩${_formatPrice(widget.price)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3182F6)),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3182F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('₩${_formatPrice(widget.price)} 결제하기', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context, false),
              child: const Text('취소', style: TextStyle(color: Colors.black45)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
