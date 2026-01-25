import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  
  AuthInterceptor(this._prefs);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(tokenKey);
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired - notify the app to re-authenticate
      // This could trigger a logout or token refresh
      _prefs.remove(tokenKey);
      _prefs.remove(refreshTokenKey);
      _prefs.remove(userIdKey);
      _prefs.remove(userRoleKey);
    }
    
    super.onError(err, handler);
  }
  
  // Helper methods for token management
  static Future<void> saveAuthData(
    SharedPreferences prefs, {
    required String token,
    String? refreshToken,
    String? userId,
    String? role,
  }) async {
    await prefs.setString(tokenKey, token);
    if (refreshToken != null) {
      await prefs.setString(refreshTokenKey, refreshToken);
    }
    if (userId != null) {
      await prefs.setString(userIdKey, userId);
    }
    if (role != null) {
      await prefs.setString(userRoleKey, role);
    }
  }
  
  static Future<void> clearAuthData(SharedPreferences prefs) async {
    await prefs.remove(tokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(userRoleKey);
  }
  
  static String? getToken(SharedPreferences prefs) => prefs.getString(tokenKey);
  static String? getUserId(SharedPreferences prefs) => prefs.getString(userIdKey);
  static String? getUserRole(SharedPreferences prefs) => prefs.getString(userRoleKey);
  static bool isLoggedIn(SharedPreferences prefs) => prefs.getString(tokenKey) != null;
}
