import 'package:competition/util/http.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/token_util.dart';

class ScoreRuleService {
  // 获取所有积分规则
  static Future<Map<String, dynamic>> getScoreRules({
    int pageNum = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await get(
        '/admin/rule/query',
        queryParameters: {
          'page_num': pageNum,
          'page_size': pageSize,
        },
      );
      // 返回包含items和total的完整数据
      return {
        'items': response.data['data']??['items'],
        'total': response.data['data']??['total'],
      };
    } catch (e) {
      // 捕获异常，避免返回null
      throw Exception('获取规则列表失败: $e');
    }
  }

  // 获取单个积分规则详情
  static Future<dynamic> getScoreRuleDetail(int id) async {
    final response = await get(
      '/admin/rule/query/$id',
    );
    return response.data['data'];
  }

  // 创建积分规则
  static Future<void> createScoreRule(Map<String, dynamic> data) async {
    try{
      // 按接口文档组装FormData
      FormData formData = FormData.fromMap({
        'event_level': data['eventLevel'] ?? '', // 赛事级别（string）
        'event_weight': data['eventWeight'] ?? 1.0, // 赛事权重（number）
        'integral': (data['baseScore'] ?? 0).toInt(), // 基础积分（integer）
        'award_level': data['awardLevel'] ?? '', // 获奖等级（string）
        'rule_desc': data['ruleDescription'] ?? '', // 规则说明（string）
        'recognized_event_id': data['recognizedEventId'] ?? '0', // 关联赛事id（string）
      });

      await postFormData(
        '/admin/rule/upload',
        formData: formData,
      );
    }
    catch (e) {
      print("创建规则错误详情: $e");
      throw Exception('创建规则失败: $e');
    }
  }

  // 更新积分规则
  static Future<Map<String, dynamic>?> updateScoreRule(String id, Map<String, dynamic> data) async {
    try {
      // 1. 校验必填参数（避免空值提交）
      if (id.isEmpty || id == 'null') {
        throw Exception('规则ID为空或无效');
      }
      if (data['eventWeight'] == null) {
        throw Exception('赛事权重不能为空');
      }
      if (data['baseScore'] == null) {
        throw Exception('基础积分不能为空');
      }
      if (data['ruleDescription']?.trim().isEmpty ?? true) {
        throw Exception('规则说明不能为空');
      }

      // 2. 组装FormData（严格匹配接口参数名）
      FormData formData = FormData.fromMap({
        'rule_id': id, // 规则ID（从方法参数传入，确保唯一）
        'event_weight': data['eventWeight'], // 赛事权重（number类型）
        'integral': (data['baseScore'] as num).toInt(), // 基础积分（转integer）
        'rule_desc': data['ruleDescription'].trim(), // 规则说明（string类型）
      });

      // 3. 发起PUT请求（正确路径+multipart/form-data格式）
      print("=== 更新接口请求信息 ===");
      print("请求路径: /admin/rule/update");
      print("请求参数: $formData");
      print("规则ID: $id");
      print("FormData参数详情:");
      print("- rule_id: $id");
      print("- event_weight: $data['eventWeight']（类型：${data['eventWeight'].runtimeType}）");
      print("- integral: ${(data['baseScore'] as num).toInt()}（类型：${(data['baseScore'] as num).toInt().runtimeType}）");
      print("- rule_desc: $data['ruleDescription'].trim()");

      Response response = await dio.put(
        '/admin/rule/update', // 接口路径
        data: formData, // 提交FormData格式
        options: Options(
          contentType: Headers.multipartFormDataContentType, // 显式指定格式
          headers: {
            // 手动添加Token（确保与删除接口一致，避免拦截器失效）
            'Access-Token': await TokenUtil.getAccessToken(),
            'Refresh-Token': await TokenUtil.getRefreshToken(),
          },
          validateStatus: (status) => status! < 500, // 允许400状态，获取后端错误
        ),
      );

      // 4. 响应校验（增强错误提示）
      print("=== 更新接口响应信息 ===");
      print("状态码: ${response.statusCode}");
      print("响应数据: ${response.data}");
      print("后端接收的参数:");
      print("- event_weight: ${response.data['data']['event_weight']}");
      print("- integral: ${response.data['data']['integral']}");
      print("- rule_desc: ${response.data['data']['rule_desc']}");

      if (response.statusCode == 400) {
        throw Exception("参数错误：${response.data['msg'] ?? response.data}");
      }
      if (response.statusCode != 200) {
        throw Exception("更新失败：${response.data['msg'] ?? '后端处理失败'}");
      }
      if (response.data is Map && response.data['code'] != null && response.data['code'] != 200) {
        throw Exception("更新失败：${response.data['msg'] ?? '未知错误'}");
      }
      // 返回更新后的响应数据
      return response.data;
    } catch (e) {
      print("=== 更新接口异常 ===");
      if (e is DioException) {
        print("Dio错误类型: ${e.type}");
        print("响应状态码: ${e.response?.statusCode}");
        print("错误信息: ${e.message}");
      } else {
        print("普通异常: $e");
      }
      throw Exception('更新失败: ${e.toString().split(':').last.trim()}');
    }
  }

  // 删除积分规则
  static Future<void> deleteScoreRule(String id) async {
    try {
      // 1. 按后端要求：用FormData传递rule_id（Body参数，multipart/form-data格式）
      if (id.isEmpty || id == 'null') {
        throw Exception('规则ID为空或无效');
      }
      print("Service层：删除规则ID = $id"); // 确认ID传递到服务层
      FormData formData = FormData.fromMap({
        'rule_id': id,
      });

      // 打印完整请求信息（便于后端联调）
      print("=== 删除接口请求信息 ===");
      print("请求路径: /admin/rule/delete");
      print("请求参数: rule_id = $id");
      print("请求方法: DELETE");
      
      Response response = await dio.delete(
        '/admin/rule/delete',
        data: FormData.fromMap({
          'rule_id': id,
        }),
        options: Options(
          headers: {
            'Access-Token': await TokenUtil.getAccessToken(),
            'Refresh-Token': await TokenUtil.getRefreshToken(),
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // 打印后端返回结果
      print("=== 删除接口响应信息 ===");
      print("后端返回状态码: ${response.statusCode}");
      print("后端返回数据: ${response.data}");

      // 根据状态码判断是否成功
      if (response.statusCode == 404) {
        throw Exception('接口不存在：请确认删除规则的正确路径');
      }
      if (response.statusCode != 200) {
        throw Exception('删除失败：${response.data['msg'] ?? '后端处理失败'}');
      }
      if (response.data is Map && response.data['code'] != null && response.data['code'] != 200) {
        throw Exception('后端处理失败: ${response.data['msg'] ?? '未知错误'}');
      }

    } catch (e) {
      print("=== 删除接口异常 ===");
      if (e is DioException) {
        print("Dio错误类型: ${e.type}");
        print("响应状态码: ${e.response?.statusCode}");
        print("响应数据: ${e.response?.data}");
        print("错误信息: ${e.message}");
      } else {
        print("普通异常: $e");
      }
      throw Exception('删除失败: ${e.toString().split(':').last.trim()}');
    }
  }
}