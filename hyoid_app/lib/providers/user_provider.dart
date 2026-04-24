import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hyoid_app/models/user_model.dart';
import 'package:hyoid_app/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _userService.getProfile();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _userService.updateProfile(data);
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadAvatar(File imageFile) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUrl = await _userService.uploadAvatar(imageFile);
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(profileImage: newUrl);
      }
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  void clearUser() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
