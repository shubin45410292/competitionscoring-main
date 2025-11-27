import 'dart:io';
import 'package:dio/dio.dart';
import 'package:competition/util/http.dart';

// 申诉模块接口路径
class AppealApiPaths {
  // 申诉申请提交接口
  static const String submitAppeal = "/upload/appeal";
}

// 申诉相关接口仓库
class AppealRepository {
  /// 提交申诉申请
  /// [request] 申诉请求参数模型
  /// 返回后端响应数据
  static Future<Response> submitAppeal(AppealRequest request) async {
    try {
      // 新增必填参数校验
    if (request.resultId.isEmpty) throw Exception("赛事材料ID不能为空");
    if (request.appealType.isEmpty || !["分级异议", "积分异议"].contains(request.appealType)) {
      throw Exception("申诉类型必须为「分级异议」或「积分异议」");
    }
    if (request.appealMessage.isEmpty) throw Exception("申诉理由不能为空");

      // 1. 将参数转换为 form-data 格式
      final formData = await request.toFormData();

      // 2. 调用 POST 接口（使用专门的 form-data 提交方法）
      final response = await postFormData(
        AppealApiPaths.submitAppeal, // 配置的接口路径
        formData: formData,
      );

      // 3. 接口文档约定成功状态码为 200，此处可添加成功校验
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception("申诉提交失败，状态码：${response.statusCode}");
      }
    } catch (e) {
      throw Exception("申诉提交异常：${e.toString()}");
    }
  }
}

/// 申诉请求参数模型
class AppealRequest {
  /// 申诉关联的赛事材料ID（必填）
  final String resultId;

  /// 申诉类型（必填：分级异议/积分异议）
  final String appealType;

  /// 申诉具体理由（必填）
  final String appealMessage;

  /// 补充材料文件（可选）
  final File? attachmentFile;

  AppealRequest({
    required this.resultId,
    required this.appealType,
    required this.appealMessage,
    this.attachmentFile,
  });

  /// 转换为 multipart/form-data 格式
  Future<FormData> toFormData() async {
    final formData = FormData();

    // 添加必填参数
    formData.fields.add(MapEntry("result_id", resultId));
    formData.fields.add(MapEntry("appeal_type", appealType));
    formData.fields.add(MapEntry("appeal_message", appealMessage));

    // 可选：添加补充材料（如果有文件）
    if (attachmentFile != null) {
      String fileName = attachmentFile!.path.split('/').last; // 获取文件名
      String contentType = '';
      // 根据文件后缀设置contentType
      if (fileName.endsWith('.pdf')) contentType = 'application/pdf';
      else if (fileName.endsWith('.doc')) contentType = 'application/msword';
      else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) contentType = 'image/jpeg';
      else if (fileName.endsWith('.png')) contentType = 'image/png';
      formData.files.add(
        MapEntry(
          "attachment_path", // 与接口文档中 Body 参数名一致
          await MultipartFile.fromFile(
            attachmentFile!.path,
            filename: fileName, // 必须添加文件名
            contentType: contentType.isNotEmpty ? DioMediaType.parse(contentType) : null, // 添加文件类型
          ),
        ),
      );
    }
    print("提交的FormData：${formData.fields}，文件：${formData.files}"); // 打印参数
    return formData;
  }
}