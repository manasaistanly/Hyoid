// lib/services/auth_service.dart
// ─────────────────────────────────────────────────────────────
// Handles all authentication API calls:
//   1. login()        — email/password (existing)
//   2. register()     — email/password (existing)
//   3. googleSignIn() — Google OAuth ID token → server (NEW)
//   4. sendOtp()      — POST /api/auth/send-otp (NEW)
//   5. verifyOtp()    — POST /api/auth/verify-otp (NEW)
//   6. getMe()        — GET /api/auth/me (includes requiresPayment)
//   7. logout()       — clear secure storage
//
// All successful auth calls store accessToken + refreshToken in
// FlutterSecureStorage. Returns AuthResult with user + requiresPayment.
//
// Connects to: AuthProvider → LoginScreen / SplashScreen
// ─────────────────────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/user_model.dart';

/// Wraps the server's auth response into a typed result.
class AuthResult {
  final UserModel user;
  final bool requiresPayment;

  const AuthResult({required this.user, required this.requiresPayment});
}

class AuthService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  // ── Private helpers ──────────────────────────────────────────

  /// Stores access + refresh tokens in secure storage.
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  /// Builds an AuthResult from a server data map.
  AuthResult _parseAuthResult(Map<String, dynamic> data) {
    final user = UserModel.fromJson(data);
    return AuthResult(
      user: user,
      requiresPayment: data['requiresPayment'] == true,
    );
  }

  // ── 1. Email Login ───────────────────────────────────────────

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      final data = response.data['data'];
      await _saveTokens(data['accessToken'], data['refreshToken']);
      return UserModel.fromJson(data);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  // ── 2. Email Register ────────────────────────────────────────

  Future<UserModel> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(ApiConstants.register, data: userData);
      final data = response.data['data'];
      await _saveTokens(data['accessToken'], data['refreshToken']);
      return UserModel.fromJson(data);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  // ── 3. Google Sign-In (NEW) ──────────────────────────────────

  /// Triggers the native Google sign-in flow (v7 API), obtains the ID token,
  /// sends it to the backend for server-side verification, and returns
  /// an AuthResult containing the user and payment requirement flag.
  Future<AuthResult> googleSignIn() async {
    try {
      // Step 1: Initialize Google Sign-In (v7 requires explicit init)
      await GoogleSignIn.instance.initialize();

      // Step 2: Trigger Google native sign-in (v7 uses authenticate())
      // authenticate() throws if cancelled, returns non-null on success
      final result = await GoogleSignIn.instance.authenticate();

      // Step 3: Get ID token from authentication data
      final idToken = result.authentication.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // Step 4: Send idToken to backend for server-side verification
      final response = await _dio.post(
        ApiConstants.googleSignIn,
        data: {'idToken': idToken},
      );

      final data = response.data['data'];
      await _saveTokens(data['accessToken'], data['refreshToken']);

      return _parseAuthResult(data);
    } on DioException catch (e) {
      throw DioClient().handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  // ── 4. Send OTP (NEW) ────────────────────────────────────────

  /// Sends a 6-digit OTP via SMS to the given phone number.
  /// Returns true on success, throws on error.
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _dio.post(
        ApiConstants.sendOtp,
        data: {'phoneNumber': phoneNumber},
      );
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  // ── 5. Verify OTP (Firebase) ─────────────────────────────────

  /// Verifies the OTP entered by the user (legacy Twilio fallback).
  Future<AuthResult> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {'phoneNumber': phoneNumber, 'otp': otp},
      );

      final data = response.data['data'];
      await _saveTokens(data['accessToken'], data['refreshToken']);

      return _parseAuthResult(data);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  // ── 5b. Verify Firebase ID Token ─────────────────────────────

  /// Exchanges a Firebase Phone Auth ID token for a backend JWT session.
  /// The backend verifies the Firebase token server-side and returns
  /// the user + accessToken + refreshToken.
  Future<AuthResult> verifyFirebaseToken(String firebaseIdToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyFirebaseToken,
        data: {'firebaseToken': firebaseIdToken},
      );

      final data = response.data['data'];
      await _saveTokens(data['accessToken'], data['refreshToken']);

      return _parseAuthResult(data);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  // ── 6. Get Me ────────────────────────────────────────────────

  /// Fetches the current user from the server.
  /// The response includes requiresPayment so the splash screen
  /// can route accordingly.
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.getMe);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  // ── 7. Device Token ──────────────────────────────────────────

  Future<void> updateDeviceToken(String token) async {
    try {
      await _dio.put(
        ApiConstants.updateDeviceToken,
        data: {'deviceToken': token},
      );
    } catch (e) {
      // Background failure is acceptable
    }
  }

  // ── 8. Logout ────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore if Google Sign-In was never used
    }
    await _storage.deleteAll();
  }

  // ── 9. Token helpers ─────────────────────────────────────────

  Future<String?> getAccessToken() async {
    return _storage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: 'refreshToken');
  }
}
