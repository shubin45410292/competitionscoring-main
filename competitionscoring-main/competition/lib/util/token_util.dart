import 'package:shared_preferences/shared_preferences.dart';

class TokenUtil {
  static const _accessTokenKey = "access_token";
  static const _refreshTokenKey = "refresh_token";
  static const _userIdKey = "user_id"; // 新增userId存储键

  // 保存 Token 到本地
  static Future<void> saveTokens(String access, String refresh, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, access);
    await prefs.setString(_refreshTokenKey, refresh);
    await prefs.setString(_userIdKey, userId); // 保存userId
  }

  // 获取本地存储的 AccessToken
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // 获取本地存储的 RefreshToken
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // 新增：获取本地存储的 userId
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
  // 清除本地 Token
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey); // 清除userId
  }
}
