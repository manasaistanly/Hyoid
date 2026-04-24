import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../core/errors/failures.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  Failure? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  Failure? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> fetchNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _service.getNotifications();
      _setLoading(false);
    } catch (e) {
      _error = e is Failure ? e : UnknownFailure(e.toString());
      _setLoading(false);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await NotificationService.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
        notifyListeners();
      }
    } catch (e) {
      // Background failure
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      _notifications = _notifications
          .map((n) => n.copyWith(read: true))
          .toList();
      notifyListeners();
    } catch (e) {
      // background failure
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }
}
