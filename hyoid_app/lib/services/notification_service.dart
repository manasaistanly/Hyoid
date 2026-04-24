import 'package:dio/dio.dart';
import 'dart:async';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = DioClient().dio;

  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  static int _unreadCount = 0;
  static final StreamController<List<NotificationModel>>
  _notificationsController =
      StreamController<List<NotificationModel>>.broadcast();
  static final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();

  // Private constructor
  NotificationService._internal();

  // Factory constructor for singleton
  factory NotificationService() {
    return _instance;
  }

  // Static methods and getters
  static Stream<List<NotificationModel>> get notificationsStream =>
      _notificationsController.stream;

  static Stream<int> get unreadCountStream => _unreadCountController.stream;

  static int get unreadCount => _unreadCount;

  static Future<void> initialize() async {
    // Load initial notifications
    try {
      final notifications = await _instance.getNotifications();
      _unreadCount = notifications.where((n) => !n.isRead).length;
      _notificationsController.add(notifications);
      _unreadCountController.add(_unreadCount);
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> markAsRead(String? id) async {
    if (id == null || id.isEmpty) return;
    try {
      await NotificationService._instance.markAsReadInstance(id);
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      _unreadCountController.add(_unreadCount);
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      await NotificationService._instance.markAllAsReadInstance();
      _unreadCount = 0;
      _unreadCountController.add(_unreadCount);
    } catch (e) {
      // Handle error silently
    }
  }

  // Instance methods
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.getNotifications);
      final list = response.data['data'] as List;
      return list.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<void> markAsReadInstance(String id) async {
    try {
      await _dio.put('${ApiConstants.markAsRead}$id/read');
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }

  Future<void> markAllAsReadInstance() async {
    try {
      await _dio.put(ApiConstants.markAllRead);
    } catch (e) {
      throw DioClient().handleError(e);
    }
  }
}
