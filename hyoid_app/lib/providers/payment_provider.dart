// lib/providers/payment_provider.dart
// ─────────────────────────────────────────────────────────────
// Manages Razorpay payment state.
//
// States (PaymentStatus enum):
//   idle           — no payment in progress
//   creatingOrder  — calling POST /api/payment/create-order
//   awaitingPayment — Razorpay SDK is open
//   verifying      — calling POST /api/payment/verify
//   success        — payment verified, user marked paid
//   failed         — payment failed or signature mismatch
//
// Flow:
//   PaymentScreen calls createAndLaunchPayment(context)
//     → createOrder() → open Razorpay SDK
//     → onPaymentSuccess() → verifyPayment() → notify AuthProvider
//     → navigate to home on success
//
// Connects to: PaymentScreen, AuthProvider.markAsPaid()
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/payment_service.dart';

enum PaymentStatus { idle, creatingOrder, awaitingPayment, verifying, success, failed }

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  PaymentStatus _status = PaymentStatus.idle;
  String? _errorMessage;
  String? _currentOrderId;

  late Razorpay _razorpay;

  /// Callback invoked after verified payment — wires to AuthProvider.markAsPaid()
  VoidCallback? onPaymentVerified;

  PaymentStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading =>
      _status == PaymentStatus.creatingOrder || _status == PaymentStatus.verifying;

  // ── Initialise Razorpay SDK ──────────────────────────────────

  void initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  void disposeRazorpay() {
    _razorpay.clear();
  }

  // ── Create Order & Launch Razorpay ───────────────────────────

  /// Called by PaymentScreen "Pay Now" button.
  /// Creates the order on the backend and opens Razorpay checkout.
  Future<void> createAndLaunchPayment({String? userName, String? userEmail, String? userPhone}) async {
    _setStatus(PaymentStatus.creatingOrder);
    try {
      final order = await _paymentService.createOrder();
      _currentOrderId = order.orderId;

      final options = {
        'key': order.keyId,
        'amount': order.amount,
        'currency': order.currency,
        'name': 'Hyoid Health',
        'description': order.planDescription,
        'order_id': order.orderId,
        if (userName != null) 'prefill': {
          'name': userName,
          'email': ?userEmail,
          'contact': ?userPhone,
        },
        'theme': {'color': '#FF6600'},
      };

      _setStatus(PaymentStatus.awaitingPayment);
      _razorpay.open(options);
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(PaymentStatus.failed);
    }
  }

  // ── Razorpay Callbacks ───────────────────────────────────────

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    _setStatus(PaymentStatus.verifying);
    try {
      final verified = await _paymentService.verifyPayment(
        razorpayOrderId: _currentOrderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      if (verified) {
        onPaymentVerified?.call(); // Notify AuthProvider
        _setStatus(PaymentStatus.success);
      } else {
        _errorMessage = 'Payment verification failed. Please contact support.';
        _setStatus(PaymentStatus.failed);
      }
    } catch (e) {
      _errorMessage = 'Payment verification error: ${e.toString()}';
      _setStatus(PaymentStatus.failed);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    _errorMessage = response.message ?? 'Payment failed. Please try again.';
    _setStatus(PaymentStatus.failed);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // External wallet selected — wait for webhook (treat as pending)
    _errorMessage = 'External wallet: ${response.walletName}. Please complete payment.';
    _setStatus(PaymentStatus.failed);
  }

  // ── Reset ────────────────────────────────────────────────────

  void reset() {
    _errorMessage = null;
    _currentOrderId = null;
    _setStatus(PaymentStatus.idle);
  }

  // ── Private ──────────────────────────────────────────────────

  void _setStatus(PaymentStatus s) {
    _status = s;
    notifyListeners();
  }
}
