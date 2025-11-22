import 'package:dio/dio.dart';
import 'package:competition/util/token_util.dart';

// 后端基础URL
const String baseUrl = "http://204.152.192.27:8080/api";

// 创建Dio实例并添加拦截器
final Dio dio = Dio(BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 5),
  headers: {
    "Content-Type": "application/json", // 显式指定JSON格式
  },
))..interceptors.add(
  InterceptorsWrapper(
    // 请求发送前拦截：添加Token到请求头
    onRequest: (options, handler) async {
      // 从本地获取Token
      final accessToken = await TokenUtil.getAccessToken();
      final refreshToken = await TokenUtil.getRefreshToken();

      // 如果Token存在，添加到请求头
      if (accessToken != null) {
        options.headers["Access-Token"] = accessToken;
      }

      if (refreshToken != null) {
        options.headers["Refresh-Token"] = refreshToken;
      }
      // print("2");
      // print(options.headers["Access-Token"] );
      // print(options.headers["Refresh-Token"]);
      handler.next(options); // 继续发送请求
    },
  ),
);

// POST请求封装
Future<Response> post(String path, {dynamic data}) async {
  try {
    Response response = await dio.post(path, data: data);
    return response;
  } catch (e) {
    throw Exception("POST请求失败：${_formatError(e)}");
  }
}

// GET请求封装（支持查询参数queryParameters）
Future<Response> get(
    String path, {
      Map<String, dynamic>? queryParameters, // 专门用于GET请求的查询参数
    }) async {
  try {
    // 1. 拼接基础URL和路径（baseUrl在dio初始化时已设置，如"http://204.152.192.27:8080/api"）
    String fullUrl = "${dio.options.baseUrl}$path";

    // 2. 如果有查询参数，拼接成?key=value&key2=value2格式
    if (queryParameters != null && queryParameters.isNotEmpty) {
      List<String> queryParts = [];
      queryParameters.forEach((key, value) {
        // 对参数值进行URL编码（避免特殊字符导致错误）
        queryParts.add("$key=${Uri.encodeComponent(value.toString())}");
      });
      fullUrl += "?${queryParts.join('&')}";
    }

    // 3. 打印完整URL
    print("最终请求URL：$fullUrl");

    // 4. 执行请求
    Response response = await dio.get(
      path,
      queryParameters: queryParameters,
    );
    return response;
  } catch (e) {
    throw Exception("GET请求失败：${_formatError(e)}");
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
Future<Response> put(String path, {dynamic data}) async {
  try {
    Response response = await dio.put(path, data: data);
    return response;
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

