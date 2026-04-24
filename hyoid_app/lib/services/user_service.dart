import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hyoid_app/core/constants/api_constants.dart';
import 'package:hyoid_app/core/network/dio_client.dart';
import 'package:hyoid_app/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyoid_app/models/user_profile_model.dart';

class UserService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.getProfile);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiConstants.updateProfile, data: data);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<String> uploadAvatar(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        ApiConstants.uploadAvatar,
        data: formData,
      );

      return response.data['url'];
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<void> clearProfile() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  static Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile.fromMap({
      'user_id': prefs.getString('user_id') ?? '',
      'user_name': prefs.getString('user_name') ?? '',
      'user_phone': prefs.getString('user_phone') ?? '',
      'user_email': prefs.getString('user_email') ?? '',
      'user_dob': prefs.getString('user_dob') ?? '',
      'user_blood_group': prefs.getString('user_blood_group') ?? '',
      'user_emergency_contact': prefs.getString('user_emergency_contact') ?? '',
      'user_role': prefs.getString('user_role') ?? 'patient',
    });
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', profile.userId);
    await prefs.setString('user_name', profile.name);
    await prefs.setString('user_phone', profile.phone);
    await prefs.setString('user_email', profile.email);
    await prefs.setString('user_dob', profile.dob);
    await prefs.setString('user_blood_group', profile.bloodGroup);
    await prefs.setString('user_emergency_contact', profile.emergencyContact);
    await prefs.setString('user_role', profile.role);
  }

  static Future<String?> getToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'accessToken');
  }

  static Future<void> clearProfileStatic() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
  }
}
