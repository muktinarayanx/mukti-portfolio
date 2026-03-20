// Central place to configure the backend base URL
// Change this to your machine's IP when testing on a real device
class AppConstants {
  static const String baseUrl = 'https://pdf-sender-app-production.up.railway.app'; // Live server
  // static const String baseUrl = 'http://localhost:5000'; // iOS simulator
  // static const String baseUrl = 'http://192.168.x.x:5000'; // Real device (use your PC IP)

  static const String registerEndpoint = '/api/auth/register';
  static const String loginEndpoint = '/api/auth/login';
  static const String meEndpoint = '/api/auth/me';
  static const String uploadEndpoint = '/api/pdf/upload';
  static const String listEndpoint = '/api/pdf/list';
  static const String downloadLogsEndpoint = '/api/pdf/download-logs';
  static const String fcmRegisterEndpoint = '/api/fcm/register-token';
  static String downloadEndpoint(String id) => '/api/pdf/download/$id';
  static String deleteEndpoint(String id) => '/api/pdf/$id';
}
