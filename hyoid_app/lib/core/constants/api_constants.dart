class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.172.124.123/api',
  );

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String getMe = '/auth/me';
  static const String updateDeviceToken = '/auth/device-token';

  // Social / OTP auth endpoints (NEW)
  static const String googleSignIn = '/auth/google';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String verifyFirebaseToken = '/auth/verify-firebase'; // Firebase Phone OTP

  // User / Profile endpoints (NEW)
  static const String getProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String uploadAvatar = '/users/upload-avatar';

  // Payment endpoints (NEW)
  static const String createOrder = '/payment/create-order';
  static const String verifyPayment = '/payment/verify';
  static const String paymentStatus = '/payment/status';

  // Appointment endpoints
  static const String createAppointment = '/appointments';
  static const String getMyAppointments = '/appointments/my';
  static const String getAppointmentById = '/appointments/';
  static const String cancelAppointment = '/appointments/';

  // Admin / Staff endpoints
  static const String getAllAppointments = '/appointments';
  static const String updateAppointment = '/appointments/';
  static const String getAssignedAppointments = '/appointments/staff/assigned';
  static const String respondToAppointment = '/appointments/';

  // Notification endpoints
  static const String getNotifications = '/notifications';
  static const String markAllRead = '/notifications/read-all';
  static const String markAsRead = '/notifications/';
}
