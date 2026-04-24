import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio dio;
  final _storage = const FlutterSecureStorage();

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _storage.read(key: 'accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('/auth/login')) {
            // Token might be expired, try to refresh
            final refreshToken = await _storage.read(key: 'refreshToken');
            if (refreshToken != null) {
              try {
                // Call refresh synchronously avoiding infinity loop
                final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
                final response = await refreshDio.post(
                  ApiConstants.refreshToken,
                  data: {'refreshToken': refreshToken},
                );
                
                final newAccessToken = response.data['data']['accessToken'];
                final newRefreshToken = response.data['data']['refreshToken'];
                
                await _storage.write(key: 'accessToken', value: newAccessToken);
                await _storage.write(key: 'refreshToken', value: newRefreshToken);
                
                // Retry original request
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              } catch (refreshError) {
                // Refresh failed, logout
                await _storage.deleteAll();
                // Optionally broadcast a global 'logout' event so UI routes to login
              }
            }
          }
          
          return handler.next(e);
        },
      ),
    );
  }

  Failure handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
        return NetworkFailure();
      }
      if (error.response != null) {
        final message = error.response?.data['message'] ?? 'An error occurred';
        if (error.response?.statusCode == 401) {
          return AuthFailure(message);
        }
        return ServerFailure(message);
      }
      return NetworkFailure();
    }
    return UnknownFailure(error.toString());
  }
}
