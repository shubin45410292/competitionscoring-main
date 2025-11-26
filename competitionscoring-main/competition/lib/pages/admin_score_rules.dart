//管理员端  积分规则页面
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:competition/util/score_rule_service.dart';
import 'package:collection/collection.dart'; // 用于安全获取列表元素

class ScoreRulesPage extends StatefulWidget {
  const ScoreRulesPage({super.key});

  @override
  State<ScoreRulesPage> createState() => _ScoreRulesPageState();
}

// 积分权重规则数据模型
class ScoreRule {
  final String ruleId;
  final String recognizedEventId;
  final String eventLevel;
  final double eventWeight;
  final double baseScore;
  final String ruleDescription;
  final bool isEditable;
  final String awardLevel;

  ScoreRule({
    required this.ruleId,
    required this.recognizedEventId,
    required this.eventLevel,
    required this.eventWeight,
    required this.baseScore,
    required this.ruleDescription,
    required this.isEditable,
    required this.awardLevel,
  });

  String get ruleName => ruleDescription;
}

class _ScoreRulesPageState extends State<ScoreRulesPage> {
  int currentPage = 1;
  final int itemsPerPage = 5; // 每页显示5条（本地分页）
  final TextEditingController _searchController = TextEditingController();
  late String formattedDate;
  List<ScoreRule> allRules = []; // 存储所有规则（一次性获取）
  List<ScoreRule> filteredRules = []; // 搜索过滤后的规则
  List<ScoreRule> currentPageRules = []; // 当前页显示的规则
  bool _isLoading = true;
  String? _errorMsg;
  int totalItems = 0; // 总规则数
  String? _highlightedRuleId; // 用于标记需要高亮的规则ID

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());
    _fetchAllScoreRules(); // 初始化时获取所有规则
  }

  // 获取所有规则（取消分页请求，一次性获取全部）
  Future<void> _fetchAllScoreRules() async {
    setState(() {
      _isLoading = true;
      allRules = [];
      filteredRules = [];
      currentPageRules = [];
    });

    try {
      final rawData = await ScoreRuleService.getScoreRules(
        pageNum: 1,
        pageSize: 100,
      );

      if (!mounted) return;
      if (rawData is! Map<String, dynamic>) {
        throw Exception('接口返回格式错误：预期Map，实际${rawData.runtimeType}');
      }

      final Map<String, dynamic> itemsMap = rawData['items'] as Map<String, dynamic>? ?? {};
      final List<dynamic> itemsList = itemsMap.values.toList();
      List<ScoreRule> validRules = [];

      for (var item in itemsList) {
        // 处理嵌套List
        if (item is List<dynamic>) {
          for (var subItem in item) {
            if (subItem is Map<String, dynamic> &&
                (subItem.containsKey('rule_id') || subItem.containsKey('rule_desc'))) {
              // 计算最新的baseScore（从后端integral字段读取）
              final double parsedBaseScore = subItem['integral'] is num
                  ? (subItem['integral'] as num).toDouble()
                  : (double.tryParse(subItem['integral'].toString()) ?? 0.0);

              // 打印调试日志（仅针对目标规则）
              if (subItem['rule_id']?.toString() == '90911') {
                debugPrint('嵌套List解析（ID:90911）：');
                debugPrint('- 后端integral: ${subItem['integral']}');
                debugPrint('- 解析baseScore: $parsedBaseScore');
              }

              validRules.add(ScoreRule(
                ruleId: subItem['rule_id']?.toString() ?? '',
                recognizedEventId: subItem['recognized_event_id']?.toString() ?? '',
                eventLevel: subItem['event_level']?.toString() ?? '未设置',
                eventWeight: subItem['event_weight'] is num
                    ? (subItem['event_weight'] as num).toDouble()
                    : (double.tryParse(subItem['event_weight'].toString()) ?? 0.0),
                baseScore: parsedBaseScore,
                ruleDescription: subItem['rule_desc']?.toString() ?? '无描述',
                isEditable: subItem['is_editable'] is bool ? subItem['is_editable'] : false,
                awardLevel: subItem['award_level']?.toString() ?? '未设置',
              ));
            }
          }
        }
        // 处理直接的Map类型
        else if (item is Map<String, dynamic> &&
            (item.containsKey('rule_id') || item.containsKey('rule_desc'))) {
          // 计算最新的baseScore（从后端integral字段读取）
          final double parsedBaseScore = item['integral'] is num
              ? (item['integral'] as num).toDouble()
              : (double.tryParse(item['integral'].toString()) ?? 0.0);

          // 打印调试日志（仅针对目标规则）
          if (item['rule_id']?.toString() == '90911') {
            debugPrint('Map解析（ID:90911）：');
            debugPrint('- 后端integral: ${item['integral']}');
            debugPrint('- 解析baseScore: $parsedBaseScore');
          }

          validRules.add(ScoreRule(
            ruleId: item['rule_id']?.toString() ?? '',
            recognizedEventId: item['recognized_event_id']?.toString() ?? '',
            eventLevel: item['event_level']?.toString() ?? '未设置',
            eventWeight: item['event_weight'] is num
                ? (item['event_weight'] as num).toDouble()
                : (double.tryParse(item['event_weight'].toString()) ?? 0.0),
            baseScore: parsedBaseScore, // 使用解析后的最新值
            ruleDescription: item['rule_desc']?.toString() ?? '无描述',
            isEditable: item['is_editable'] is bool ? item['is_editable'] : false,
            awardLevel: item['award_level']?.toString() ?? '未设置',
          ));
        }
      }

      // 设置总规则数
      dynamic total = rawData['total'];
      totalItems = total is int && total > 0 ? total : validRules.length;

      if (!mounted) return;
      setState(() {
        allRules = validRules;
        _filterRules();
        _isLoading = false;
      });

      // 调试日志：确认最终数据（使用firstWhereOrNull避免异常）
      ScoreRule? updatedRule = validRules.firstWhereOrNull((r) => r.ruleId == '90911');
      if (updatedRule != null) {
        debugPrint('最终显示数据（ID:90911）：');
        debugPrint('- eventWeight: ${updatedRule.eventWeight}');
        debugPrint('- baseScore: ${updatedRule.baseScore}');
      } else {
        debugPrint('未找到ID为90911的规则');
      }

      // 调试日志：确认数据量
      debugPrint('=== 积分规则获取完成 ===');
      debugPrint('解析后总规则数：${validRules.length}');
      debugPrint('后端返回total：$total');
      debugPrint('最终totalItems：$totalItems');

    } catch (e, stackTrace) {
      debugPrint('获取规则失败：$e');
      debugPrint('堆栈信息：$stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMsg = '获取规则失败: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  // 过滤规则（搜索功能）
  void _filterRules() {
    setState(() {
      String searchText = _searchController.text.trim().toLowerCase();
      filteredRules = allRules.where((rule) {
        // 支持按规则ID精准搜索（完全匹配）
        bool matchRuleId = rule.ruleId.toLowerCase() == searchText;
        // 模糊匹配规则名称、赛事级别、奖项级别
        bool matchFuzzy = rule.ruleName.toLowerCase().contains(searchText) ||
            rule.eventLevel.toLowerCase().contains(searchText) ||
            rule.awardLevel.toLowerCase().contains(searchText);
        // 优先精准匹配ID，再模糊匹配其他字段
        return matchRuleId || matchFuzzy;
      }).toList();
      // 搜索后自动跳转到第一页（若有匹配结果）
      currentPage = 1;
      _updateCurrentPageRules();
    });
  }

  // 更新当前页规则（本地分页逻辑）
  void _updateCurrentPageRules() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    // 防止索引越界
    if (startIndex >= filteredRules.length) {
      currentPageRules = [];
      return;
    }
    if (endIndex > filteredRules.length) {
      endIndex = filteredRules.length;
    }
    currentPageRules = filteredRules.sublist(startIndex, endIndex);
    // 若搜索结果仅1条，触发高亮动画
    if (filteredRules.length == 1) {
      _highlightSingleResult();
    }
  }

  // 高亮动画方法（增强视觉体验）
  void _highlightSingleResult() {
    if (mounted && currentPageRules.isNotEmpty) {
      // 这里用状态变量控制高亮，配合UI组件实现闪烁/变色效果
      setState(() {
        _highlightedRuleId = currentPageRules.first.ruleId;
      });
      // 2秒后取消高亮
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _highlightedRuleId = null);
        }
      });
    }
  }

  // 切换分页（上一页/下一页）
  void _changePage(int newPage) {
    setState(() {
      currentPage = newPage;
      _updateCurrentPageRules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '积分权重规则管理',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/adminHome');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 搜索栏
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (text) => _filterRules(),
                onSubmitted: (text) => _filterRules(),
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _filterRules(),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterRules();
                      setState(() => _highlightedRuleId = null); // 清空搜索时取消高亮
                    },
                  )
                      : null,
                  hintText: '搜索规则（名称/赛事级别/奖项级别/规则id）',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 规则列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                  : _errorMsg != null
                  ? Center(
                child: Text(
                  '错误: $_errorMsg',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
                  : currentPageRules.isEmpty
                  ? Center(
                child: Text(
                  filteredRules.isEmpty ? '暂无有效规则数据' : '当前页无数据',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: currentPageRules.length,
                itemBuilder: (context, index) => _buildRuleCard(currentPageRules[index]),
              ),
            ),

            // 新建按钮
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _showCreateRuleDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('新建', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 16),

            // 分页控件（本地分页，支持所有页切换）
            if (filteredRules.length > 0) _buildPagination(),
            const SizedBox(height: 10),

            // 底部状态栏
            Text(
              '$formattedDate  |  系统版本v2.3.1  |  共$totalItems条规则  |  服务状态：正常',
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 规则卡片
  Widget _buildRuleCard(ScoreRule rule) {
    // 判断是否需要高亮（搜索结果仅1条时）
    bool isHighlighted = _highlightedRuleId == rule.ruleId;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isHighlighted ? 6 : 2, // 高亮时提升阴影
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),
                                    side: isHighlighted 
                                    ? const BorderSide(color: Colors.blue, width: 2) // 高亮边框
                                    : BorderSide.none
                                    ),
      color: isHighlighted ? Colors.blue[50] : Colors.white, // 高亮背景色
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Text(
                    rule.ruleName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showEditRuleDialog(rule),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteConfirmationDialog(rule),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('赛事级别: ${rule.eventLevel}'),
            const SizedBox(height: 4),
            Text('奖项级别: ${rule.awardLevel}'),
            const SizedBox(height: 4),
            Text('赛事权重系数: ${rule.eventWeight}'),
            const SizedBox(height: 4),
            Text('基础分: ${rule.baseScore}'),
          ],
        ),
      ),
    );
  }

  // 分页控件（本地分页逻辑）
  Widget _buildPagination() {
    int totalPages = (filteredRules.length + itemsPerPage - 1) ~/ itemsPerPage;
    if (totalPages <= 1) return const SizedBox.shrink(); // 只有一页时隐藏分页

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 上一页
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? () => _changePage(currentPage - 1) : null,
          disabledColor: Colors.grey[300],
        ),
        // 页码显示
        Text(
          '$currentPage/$totalPages（共${filteredRules.length}条）',
          style: const TextStyle(fontSize: 14),
        ),
        // 下一页
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages ? () => _changePage(currentPage + 1) : null,
          disabledColor: Colors.grey[300],
        ),
      ],
    );
  }

  // 编辑规则对话框
  void _showEditRuleDialog(ScoreRule rule) {
    //final eventLevelController = TextEditingController(text: rule.eventLevel);
    //final awardLevelController = TextEditingController(text: rule.awardLevel);
    final eventWeightController = TextEditingController(text: rule.eventWeight.toString());
    final baseScoreController = TextEditingController(text: rule.baseScore.toString());
    final ruleDescriptionController = TextEditingController(text: rule.ruleDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑规则'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFormField('规则描述 *', ruleDescriptionController),
              //_buildFormField('赛事级别', eventLevelController),
              //_buildFormField('奖项级别', awardLevelController),
              _buildFormField('赛事权重系数 *', eventWeightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true)),
              _buildFormField('基础分 *', baseScoreController, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (!mounted) return;
              try {
                // 1. 前端表单校验（避免无效参数）
                String? errorMsg;
                final ruleDesc = ruleDescriptionController.text.trim();
                final eventWeight = double.tryParse(eventWeightController.text);
                final baseScore = int.tryParse(baseScoreController.text);

                if (ruleDesc.isEmpty) {
                  errorMsg = '规则说明不能为空';
                } else if (eventWeight == null) {
                  errorMsg = '赛事权重必须是数字（如1.0）';
                } else if (baseScore == null) {
                  errorMsg = '基础分必须是整数（如100）';
                }

                if (errorMsg != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMsg), backgroundColor: Colors.orange),
                  );
                  return;
                }

                // 2. 组装参数（严格匹配接口要求的key）
                final updatedRule = {
                  'ruleDescription': ruleDesc, // 前端字段名
                  'eventWeight': eventWeight,  // 前端字段名
                  'baseScore': baseScore,      // 前端字段名
                };

                // 新增日志：确认前端编辑的新值
                print("=== 前端编辑的新参数 ===");
                print("ruleDescription: $ruleDesc");
                print("eventWeight: $eventWeight（类型：${eventWeight.runtimeType}）");
                print("baseScore: $baseScore（类型：${baseScore.runtimeType}）");

                // 调用更新接口并接收响应数据
                final updateResponse = await ScoreRuleService.updateScoreRule(rule.ruleId, updatedRule);

                // 关键：从更新接口的响应中提取最新数据，直接更新本地缓存
                if (updateResponse != null && updateResponse['data'] != null) {
                  final Map<String, dynamic> latestRuleData = updateResponse['data'];
                  setState(() {
                    // 找到本地列表中对应规则并替换
                    int ruleIndex = allRules.indexWhere((r) => r.ruleId == rule.ruleId);
                    if (ruleIndex != -1) {
                      allRules[ruleIndex] = ScoreRule(
                        ruleId: latestRuleData['rule_id']?.toString() ?? rule.ruleId,
                        recognizedEventId: latestRuleData['recognized_event_id']?.toString() ?? rule.recognizedEventId,
                        eventLevel: latestRuleData['event_level']?.toString() ?? rule.eventLevel,
                        eventWeight: latestRuleData['event_weight'] is num
                            ? (latestRuleData['event_weight'] as num).toDouble()
                            : rule.eventWeight,
                        baseScore: latestRuleData['integral'] is num
                            ? (latestRuleData['integral'] as num).toDouble()
                            : rule.baseScore,
                        ruleDescription: latestRuleData['rule_desc']?.toString() ?? rule.ruleDescription,
                        isEditable: latestRuleData['is_editable'] ?? rule.isEditable,
                        awardLevel: latestRuleData['award_level']?.toString() ?? rule.awardLevel,
                      );
                      // 同步更新过滤列表和当前页数据
                      filteredRules = List.from(allRules);
                      _updateCurrentPageRules();
                    }
                  });
                }

                // 提示成功并关闭弹窗
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('规则更新成功'), backgroundColor: Colors.green),
                );
                Navigator.pop(context);

                // 延迟调用查询接口（确保后端最终同步）
                 await Future.delayed(const Duration(seconds: 1));
                 await _fetchAllScoreRules();
              } catch (e) {
                // 5. 错误提示（显示后端具体信息）
                scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('更新失败: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 删除确认对话框
  void _showDeleteConfirmationDialog(ScoreRule rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除规则 "${rule.ruleName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 1. 保存全局ScaffoldMessenger
              final scaffoldMessenger = ScaffoldMessenger.of(Navigator.of(context).context);
              Navigator.pop(context);
              
              print("待删除规则ID: ${rule.ruleId}");
              if (rule.ruleId.isEmpty || rule.ruleId == 'null') {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('删除失败：规则ID无效')),
                );
                return;
              }

              try {
                await ScoreRuleService.deleteScoreRule(rule.ruleId);
                
                // 刷新列表（仅在页面挂载时执行）
                if (mounted) {
                  await _fetchAllScoreRules();
                }
                
                // 使用全局ScaffoldMessenger显示提示
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('规则已成功删除')),
                );
              } catch (e) {
                print("删除失败详情: $e");
                // 全局提示，避免上下文问题
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('删除失败：$e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 统一创建表单格式
  Widget _buildRequiredFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onSubmitted: (value) => controller.text = value.trim(),
        ),
      ],
    );
  }

  // 新建规则对话框
  void _showCreateRuleDialog() {
    // 1. 初始化表单控制器
    final ruleDescriptionController = TextEditingController();
    final eventLevelController = TextEditingController();
    final awardLevelController = TextEditingController();
    final eventWeightController = TextEditingController(text: '1.0');
    final baseScoreController = TextEditingController();
    // 赛事ID控制器（输入0=通用规则，其他=特殊规则）
    final eventIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setState) {
            // 实时判断规则类型（根据赛事ID值）
            bool isGeneralRule() {
              return eventIdController.text.trim() == '0';
            }

            return AlertDialog(
              title: const Text('新建积分规则'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 2. 赛事ID输入框（区分通用/特殊规则）
                    const Text(
                      '赛事ID *',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: eventIdController,
                      keyboardType: TextInputType.number, // 仅允许输入数字
                      decoration: InputDecoration(
                        hintText: '输入0为通用规则，输入其他数字为特殊规则',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        // 实时提示当前规则类型
                        helperText: isGeneralRule() 
                            ? '当前为：通用规则（无需关联具体赛事）' 
                            : '当前为：特殊规则（关联赛事ID：${eventIdController.text.trim()}）',
                        helperStyle: TextStyle(
                          color: isGeneralRule() ? Colors.green : Colors.blue,
                        ),
                      ),
                      // 实时更新UI，显示当前规则类型
                      onChanged: (value) => setState(() {}),
                    ),
                    // 赛事ID非空校验提示
                    if (eventIdController.text.trim().isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          '请输入赛事ID（0=通用规则，其他=特殊规则）',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // 3. 其他固定表单项（按接口文档要求，均为必填）
                    // 规则描述
                    _buildRequiredFormField(
                      label: '规则描述 *',
                      controller: ruleDescriptionController,
                      hintText: '如“国家级赛事一等奖通用规则”',
                    ),
                    const SizedBox(height: 16),

                    // 赛事级别
                    _buildRequiredFormField(
                      label: '赛事级别 *',
                      controller: eventLevelController,
                      hintText: '如“国际级”“国家级”“省级”“校级”',
                    ),
                    const SizedBox(height: 16),

                    // 奖项级别
                    _buildRequiredFormField(
                      label: '奖项级别 *',
                      controller: awardLevelController,
                      hintText: '如“一等奖”“二等奖”“三等奖”',
                    ),
                    const SizedBox(height: 16),

                    // 赛事权重系数
                    _buildRequiredFormField(
                      label: '赛事权重系数 *',
                      controller: eventWeightController,
                      hintText: '如1.0',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),

                    // 基础分
                    _buildRequiredFormField(
                      label: '基础分 *',
                      controller: baseScoreController,
                      hintText: '如100',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                // 取消按钮
                TextButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                // 保存按钮（含完整表单校验与参数构造）
                TextButton(
                  child: const Text('保存'),
                  onPressed: () async {
                    if (!mounted) return;

                    // 4. 表单校验（严格匹配接口文档必填项）
                    String? errorMsg;
                    final eventId = eventIdController.text.trim();
                    // 赛事ID校验：非空且为纯数字
                    if (eventId.isEmpty) {
                      errorMsg = '请输入赛事ID（0=通用规则，其他=特殊规则）';
                    } else if (int.tryParse(eventId) == null) {
                      errorMsg = '赛事ID必须为数字（0=通用规则，其他=特殊规则）';
                    } else if (ruleDescriptionController.text.trim().isEmpty) {
                      errorMsg = '请输入规则描述';
                    } else if (eventLevelController.text.trim().isEmpty) {
                      errorMsg = '请输入赛事级别';
                    } else if (awardLevelController.text.trim().isEmpty) {
                      errorMsg = '请输入奖项级别';
                    } else if (eventWeightController.text.trim().isEmpty) {
                      errorMsg = '请输入赛事权重系数';
                    } else if (baseScoreController.text.trim().isEmpty) {
                      errorMsg = '请输入基础分';
                    }

                    // 校验不通过：显示错误提示
                    if (errorMsg != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMsg), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    // 5. 构造请求参数
                    final Map<String, dynamic> ruleData = {
                      'recognizedEventId': eventId, // 直接传递赛事ID（0=通用，其他=特殊）
                      'ruleDescription': ruleDescriptionController.text.trim(),
                      'eventLevel': eventLevelController.text.trim(),
                      'awardLevel': awardLevelController.text.trim(),
                      'eventWeight': double.tryParse(eventWeightController.text.trim()) ?? 1.0,
                      'baseScore': int.tryParse(baseScoreController.text.trim()) ?? 0,
                      'isEditable': false, // 固定值，非接口必填项
                    };

                    try {
                      // 6. 调用创建接口（按接口文档用postFormData）
                      await ScoreRuleService.createScoreRule(ruleData);
                      
                      // 7. 关闭弹窗并刷新列表
                      Navigator.of(dialogContext).pop();
                      await _fetchAllScoreRules();
                      
                      // 8. 成功提示（区分规则类型）
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isGeneralRule() 
                                ? '通用规则创建成功' 
                                : '特殊规则（赛事ID：$eventId）创建成功'
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // 9. 错误提示（含后端返回信息）
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('创建失败：${e.toString().replaceAll('Exception: ', '')}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 构建表单字段
  Widget _buildFormField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}