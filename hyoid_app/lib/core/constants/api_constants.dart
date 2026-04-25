import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for Web/iOS/Desktop
  static const String baseUrl = kIsWeb 
    ? "http://127.0.0.1:5000/api" 
    : "http://10.0.2.2:5000/api";
}
