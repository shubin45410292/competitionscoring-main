import 'package:dio/dio.dart'; // 假设使用dio库，需在pubspec.yaml中添加依赖

// 后端基础URL
const String baseUrl = "http://204.152.192.27:8080/api";

// 创建Dio实例（统一配置请求）
final Dio dio = Dio(BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 5),
  // 可添加默认请求头（如Token、Content-Type等）
  headers: {
    //"Content-Type": "application/json",
    // "Authorization": "Bearer {token}" // 后续可根据登录状态动态设置
  },
));

// GET请求封装
Future<T> get<T>(String path, {Map<String, dynamic>? params}) async {
  try {
    Response response = await dio.get(path, queryParameters: params);
    return response.data;
  } catch (e) {
    throw Exception("GET请求失败：${_formatError(e)}");
  }
}

// POST请求封装
Future<T> post<T>(String path, {dynamic data}) async {
  try {
    Response response = await dio.post(path, data: data);
    return response.data;
  } catch (e) {
    throw Exception("POST请求失败：${_formatError(e)}");
  }
}

// DELETE请求封装（常用于删除资源）
Future<T> delete<T>(String path, {Map<String, dynamic>? params}) async {
  try {
    Response response = await dio.delete(path, queryParameters: params);
    return response.data;
  } catch (e) {
    throw Exception("DELETE请求失败：${_formatError(e)}");
  }
}

// PUT请求封装（常用于全量更新资源）
Future<T> put<T>(String path, {dynamic data}) async {
  try {
    Response response = await dio.put(path, data: data);
    return response.data;
  } catch (e) {
    throw Exception("PUT请求失败：${_formatError(e)}");
  }
}

// PATCH请求封装（常用于部分更新资源）
Future<T> patch<T>(String path, {dynamic data}) async {
  try {
    Response response = await dio.patch(path, data: data);
    return response.data;
  } catch (e) {
    throw Exception("PATCH请求失败：${_formatError(e)}");
  }
}

// 错误信息格式化（增强错误可读性）
String _formatError(dynamic e) {
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "连接超时";
      case DioExceptionType.sendTimeout:
        return "发送超时";
      case DioExceptionType.receiveTimeout:
        return "接收超时";
      case DioExceptionType.badResponse:
        return "服务器错误（状态码：${e.response?.statusCode}）";
      case DioExceptionType.cancel:
        return "请求已取消";
      default:
        return e.message ?? "网络错误";
    }
  }
  return e.toString();
}