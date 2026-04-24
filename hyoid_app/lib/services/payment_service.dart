// lib/services/payment_service.dart
// ─────────────────────────────────────────────────────────────
// Handles Razorpay payment API calls:
//   createOrder()     — POST /api/payment/create-order
//   verifyPayment()   — POST /api/payment/verify
//   getPaymentStatus() — GET /api/payment/status
//
// Called by PaymentProvider → PaymentScreen.
// JWT token is automatically attached by DioClient interceptor.
// ─────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';

/// Data returned by createOrder — passed directly to Razorpay SDK.
class RazorpayOrder {
  final String orderId;
  final int amount;
  final String currency;
  final String keyId;
  final String planName;
  final String planDescription;

  const RazorpayOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
    required this.planName,
    required this.planDescription,
  });
}

class PaymentService {
  final Dio _dio = DioClient().dio;

  // ── Create Razorpay Order ────────────────────────────────────

  /// Calls the backend to create a Razorpay order.
  /// Returns order details including keyId (needed by Flutter SDK).
  Future<RazorpayOrder> createOrder() async {
    try {
      final response = await _dio.post(ApiConstants.createOrder);
      final data = response.data['data'];
      final plan = data['plan'] as Map<String, dynamic>;

      return RazorpayOrder(
        orderId: data['orderId'],
        amount: data['amount'],
        currency: data['currency'],
        keyId: data['keyId'],
        planName: plan['name'] ?? 'Hyoid Health Plan',
        planDescription: plan['description'] ?? 'Full access to Hyoid healthcare services',
      );
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  // ── Verify Payment ───────────────────────────────────────────

  /// Sends Razorpay payment details to the backend for HMAC verification.
  /// On success, the backend marks user.isPaid = true.
  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyPayment,
        data: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  // ── Get Payment Status ───────────────────────────────────────

  /// Returns whether the current user has completed payment.
  Future<bool> getPaymentStatus() async {
    try {
      final response = await _dio.get(ApiConstants.paymentStatus);
      return response.data['data']['isPaid'] == true;
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }
}
