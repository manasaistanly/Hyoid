// lib/providers/auth_provider.dart
// ─────────────────────────────────────────────────────────────
// Manages authentication state for the entire app.
//
// States (AuthStatus enum):
//   initial          — app just started, pre-check
//   loading          — startup token validation in progress
//   guest            — no token: browsing freely (NEW)
//   googleLoading    — Google Sign-In in progress
//   otpSending       — POST /api/auth/send-otp in progress
//   otpSent          — OTP sent, waiting for user input
//   otpVerifying     — POST /api/auth/verify-otp in progress
//   authenticated    — logged in (check requiresPayment)
//   error            — error occurred (see errorMessage)
//
// App-open flow:
//   no token  → guest    → HomeScreen (not LoginScreen)
//   valid tok → authenticated → HomeScreen
//   failed    → guest    → HomeScreen (not LoginScreen)
//
// After successful login: PendingActionService.executePending() is called
// so any blocked guest action fires automatically.
//
// Logout → guest → user stays on HomeScreen, browsing continues.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/errors/failures.dart';
import '../core/auth/post_login_redirect.dart';

enum AuthStatus {
  initial,
  loading,
  guest, // browsing without an account
  googleLoading,
  otpSending,
  otpSent,
  otpVerifying,
  authenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _requiresPayment = false;

  // ── Getters ──────────────────────────────────────────────────

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get requiresPayment => _requiresPayment;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;

  /// True when the user has no session — browsing as a guest.
  bool get isGuest =>
      _status == AuthStatus.guest || _status == AuthStatus.initial;

  // Legacy compat — true during any loading state
  bool get isLoading =>
      _status == AuthStatus.loading ||
      _status == AuthStatus.googleLoading ||
      _status == AuthStatus.otpSending ||
      _status == AuthStatus.otpVerifying;

  Failure? get error =>
      _errorMessage != null ? UnknownFailure(_errorMessage!) : null;

  // ── Initialize (app start) ───────────────────────────────────

  /// Called from SplashScreen. Checks for stored token → /api/auth/me.
  /// On success → authenticated state.
  /// On failure (no token / expired) → GUEST state (not login screen).
  Future<void> initialize() async {
    _setStatus(AuthStatus.loading);
    try {
      _currentUser = await _authService.getMe();
      _requiresPayment = _currentUser!.requiresPayment;
      _setStatus(AuthStatus.authenticated);
    } catch (e) {
      // No valid token — become a guest, not force login
      _currentUser = null;
      _requiresPayment = false;
      _setStatus(AuthStatus.guest);
    }
  }

  // ── Email Login ──────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _setStatus(AuthStatus.loading);
    try {
      _currentUser = await _authService.login(email, password);
      _requiresPayment = _currentUser!.requiresPayment;
      _setStatus(AuthStatus.authenticated);
      _executePending();
      return true;
    } catch (e) {
      _errorMessage = _extractMessage(e);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // ── Email Register ────────────────────────────────────────────

  Future<bool> register(Map<String, dynamic> data) async {
    _setStatus(AuthStatus.loading);
    try {
      _currentUser = await _authService.register(data);
      _requiresPayment = _currentUser!.requiresPayment;
      _setStatus(AuthStatus.authenticated);
      _executePending();
      return true;
    } catch (e) {
      _errorMessage = _extractMessage(e);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────

  Future<bool> googleSignIn() async {
    _setStatus(AuthStatus.googleLoading);
    try {
      final result = await _authService.googleSignIn();
      _currentUser = result.user;
      _requiresPayment = result.requiresPayment;
      _setStatus(AuthStatus.authenticated);
      _executePending();
      return true;
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        _setStatus(AuthStatus.guest);
        return false;
      }
      _errorMessage = _extractMessage(e);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // ── OTP: Send (Firebase Phone Auth) ─────────────────────────

  String? _verificationId; // stored from Firebase callback

  Future<bool> sendOtp(String phoneNumber) async {
    _setStatus(AuthStatus.otpSending);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval on Android — sign in immediately
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _errorMessage = e.message ?? 'OTP verification failed';
          _setStatus(AuthStatus.error);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setStatus(AuthStatus.otpSent);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } catch (e) {
      _errorMessage = _extractMessage(e);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // ── OTP: Verify (Firebase Phone Auth) ────────────────────────

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    if (_verificationId == null) {
      _errorMessage = 'Session expired. Please request OTP again.';
      _setStatus(AuthStatus.error);
      return false;
    }
    _setStatus(AuthStatus.otpVerifying);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      return await _signInWithCredential(credential);
    } catch (e) {
      _errorMessage = _extractMessage(e);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  /// Signs in with a Firebase credential, then exchanges the Firebase ID token
  /// with the backend to get a session JWT.
  Future<bool> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user!.getIdToken();

      // Exchange Firebase ID token with YOUR backend → get app JWT
      final result = await _authService.verifyFirebaseToken(idToken!);
      _currentUser = result.user;
      _requiresPayment = result.requiresPayment;
      _setStatus(AuthStatus.authenticated);
      _executePending();
      return true;
    } catch (e) {
      _errorMessage = _extractMessage(e);
      _setStatus(AuthStatus.error);
      return false;
    }
  }

  // ── Mark Paid ─────────────────────────────────────────────────

  void markAsPaid() {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        isPaid: true,
        requiresPayment: false,
      );
      _requiresPayment = false;
      notifyListeners();
    }
  }

  // ── Logout ────────────────────────────────────────────────────

  /// Clears session → guest mode. User stays on current screen.
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _requiresPayment = false;
    pendingActionService.clear();
    _setStatus(AuthStatus.guest); // guest, not initial — no forced login
  }

  // ── Private helpers ───────────────────────────────────────────

  /// After every successful login/register/OTP verify → fire pending action.
  void _executePending() {
    // Small delay so the UI can settle before the navigation fires
    Future.delayed(const Duration(milliseconds: 300), () {
      pendingActionService.executePending();
    });
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    if (status != AuthStatus.error) _errorMessage = null;
    notifyListeners();
  }

  String _extractMessage(dynamic e) {
    if (e is Failure) return e.message;
    final msg = e.toString();
    if (msg.contains('message:')) {
      return msg.split('message:').last.trim();
    }
    return msg;
  }
}
