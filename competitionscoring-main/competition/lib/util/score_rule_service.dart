import 'package:competition/util/http.dart';

class ScoreRuleService {
  // 获取所有积分规则
  static Future<Map<String, dynamic>> getScoreRules({
    int pageNum = 1,
    int pageSize = 10,
    String? keyword,
    int? type, // 1:通用规则 2:特殊规则
  }) async {
    try {
      final response = await get(
        '/admin/rule/query',
        queryParameters: {
          'page_num': pageNum,
          'page_size': pageSize,
        },
      );
      //print(response);
      //print(response.data);
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
  /*static Future<dynamic> getScoreRuleDetail(int id) async {
    final response = await get(
      '/admin/rule/query/$id',
    );
    return response.data['data'];
  }*/

  // 创建积分规则
  static Future<void> createScoreRule(Map<String, dynamic> data) async {
    try{
      await post(
        '/admin/rule/upload',
        data: {
          'event_level': data['eventLevel'] ?? '', // 用前端传入的赛事级别
          'event_weight': data['eventWeight'] ?? 1.0, // 用前端传入的赛事权重
          'integral': data['baseScore'] ?? 0, // 对应接口的“基础分”字段（参考接口文档）
          'award_level': data['awardLevel'] ?? '', // 用前端传入的奖项级别
          'rule_desc': data['ruleDescription'] ?? '', // 对应接口的“规则描述”字段
          'recognized_event_id': data['recognizedEventId'] ?? 0, // 用前端传入的赛事ID
        },
      );
    }
    catch (e) {
      throw Exception('创建规则失败: $e');
    }
  }

  // 更新积分规则
  static Future<void> updateScoreRule(String id, Map<String, dynamic> data) async {
    await put(
      '/admin/rule/update/$id',
      data: data,
    );
  }

  // 删除积分规则
  static Future<void> deleteScoreRule(String id) async {
    await delete(
      '/admin/rule/delete/$id',
    );
  }
}
