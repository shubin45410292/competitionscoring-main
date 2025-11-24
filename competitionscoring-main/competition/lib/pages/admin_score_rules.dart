//管理员端  积分规则页面
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:competition/util/score_rule_service.dart';

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

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());
    _fetchAllScoreRules(); // 初始化时获取所有规则
  }

  // 关键修改：获取所有规则（取消分页请求，一次性获取全部）
  Future<void> _fetchAllScoreRules() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _errorMsg = null;
        allRules = [];
      });

      // 发起请求：取消pageNum和pageSize参数（或传空，让后端返回全部）
      // 若后端强制要求分页参数，可传 pageNum=1, pageSize=100（确保覆盖44条）
      final rawData = await ScoreRuleService.getScoreRules(
        pageNum: 1, // 固定第一页
        pageSize: 100, 
      );

      if (!mounted) return;

      if (rawData is! Map<String, dynamic>) {
        throw Exception('接口返回格式错误：预期Map，实际${rawData.runtimeType}');
      }

      // 提取并解析所有规则（处理嵌套List结构）
      final Map<String, dynamic> itemsMap = rawData['items'] as Map<String, dynamic>? ?? {};
      final List<dynamic> itemsList = itemsMap.values.toList();
      List<ScoreRule> validRules = [];

      // 解析所有层级的数据（支持嵌套List）
      for (var item in itemsList) {
        // 处理嵌套List（核心：提取所有层级的规则）
        if (item is List<dynamic>) {
          for (var subItem in item) {
            if (subItem is Map<String, dynamic> &&
                (subItem.containsKey('rule_id') || subItem.containsKey('rule_desc'))) {
              validRules.add(ScoreRule(
                ruleId: subItem['rule_id']?.toString() ?? '',
                recognizedEventId: subItem['recognized_event_id']?.toString() ?? '',
                eventLevel: subItem['event_level']?.toString() ?? '未设置',
                eventWeight: subItem['event_weight'] is num
                    ? (subItem['event_weight'] as num).toDouble()
                    : (double.tryParse(subItem['event_weight'].toString()) ?? 0.0),
                baseScore: subItem['integral'] is num
                    ? (subItem['integral'] as num).toDouble()
                    : (double.tryParse(subItem['integral'].toString()) ?? 0.0),
                ruleDescription: subItem['rule_desc']?.toString() ?? '无描述',
                isEditable: subItem['is_editable'] is bool ? subItem['is_editable'] : false,
                awardLevel: subItem['award_level']?.toString() ?? '未设置',
              ));
            }
          }
        }
        // 处理直接的Map类型规则
        else if (item is Map<String, dynamic> &&
            (item.containsKey('rule_id') || item.containsKey('rule_desc'))) {
          validRules.add(ScoreRule(
            ruleId: item['rule_id']?.toString() ?? '',
            recognizedEventId: item['recognized_event_id']?.toString() ?? '',
            eventLevel: item['event_level']?.toString() ?? '未设置',
            eventWeight: item['event_weight'] is num
                ? (item['event_weight'] as num).toDouble()
                : (double.tryParse(item['event_weight'].toString()) ?? 0.0),
            baseScore: item['integral'] is num
                ? (item['integral'] as num).toDouble()
                : (double.tryParse(item['integral'].toString()) ?? 0.0),
            ruleDescription: item['rule_desc']?.toString() ?? '无描述',
            isEditable: item['is_editable'] is bool ? item['is_editable'] : false,
            awardLevel: item['award_level']?.toString() ?? '未设置',
          ));
        }
      }

      // 关键：设置总规则数（优先用后端返回的total，若无效则用解析后的数量）
      dynamic total = rawData['total'];
      totalItems = total is int && total > 0 ? total : validRules.length;

      if (!mounted) return;

      setState(() {
        allRules = validRules;
        _filterRules(); // 初始化过滤（无搜索条件时显示所有）
        _isLoading = false;
      });

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
      String searchText = _searchController.text.toLowerCase();
      // 搜索过滤：匹配规则名称、赛事级别、奖项级别
      filteredRules = allRules.where((rule) {
        return rule.ruleName.toLowerCase().contains(searchText) ||
            rule.eventLevel.toLowerCase().contains(searchText) ||
            rule.awardLevel.toLowerCase().contains(searchText);
      }).toList();
      // 过滤后重置到第一页
      currentPage = 1;
      _updateCurrentPageRules(); // 更新当前页数据
    });
  }

  // 关键修改：更新当前页规则（本地分页逻辑）
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
                    },
                  )
                      : null,
                  hintText: '搜索规则（名称/赛事级别/奖项级别）',
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  // 编辑规则对话框（保持不变）
  void _showEditRuleDialog(ScoreRule rule) {
    final eventLevelController = TextEditingController(text: rule.eventLevel);
    final awardLevelController = TextEditingController(text: rule.awardLevel);
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
              _buildFormField('规则描述', ruleDescriptionController),
              _buildFormField('赛事级别', eventLevelController),
              _buildFormField('奖项级别', awardLevelController),
              _buildFormField('赛事权重系数', eventWeightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true)),
              _buildFormField('基础分', baseScoreController, keyboardType: TextInputType.number),
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
              if (!mounted) return;
              try {
                final updatedRule = {
                  'recognizedEventId': rule.recognizedEventId,
                  'eventLevel': eventLevelController.text,
                  'eventWeight': double.tryParse(eventWeightController.text) ?? rule.eventWeight,
                  'baseScore': double.tryParse(baseScoreController.text) ?? rule.baseScore,
                  'ruleDescription': ruleDescriptionController.text,
                  'isEditable': rule.isEditable,
                  'awardLevel': awardLevelController.text,
                };
                await ScoreRuleService.updateScoreRule(rule.ruleId, updatedRule);
                Navigator.pop(context);
                _fetchAllScoreRules(); // 重新获取所有规则，刷新列表
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('规则已更新')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('更新失败: ${e.toString()}')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 删除确认对话框（保持不变）
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
              if (!mounted) return;
              try {
                await ScoreRuleService.deleteScoreRule(rule.ruleId);
                Navigator.pop(context);
                _fetchAllScoreRules(); // 重新获取所有规则，刷新列表
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('规则已删除')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('删除失败: ${e.toString()}')),
                );
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 新建规则对话框（保持不变）
  void _showCreateRuleDialog() {
    final eventLevelController = TextEditingController();
    final awardLevelController = TextEditingController();
    final eventWeightController = TextEditingController(text: '1.0');
    final awardWeightController = TextEditingController(text: '1.0');
    final baseScoreController = TextEditingController();
    final ruleDescriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建积分规则'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFormField('规则描述', ruleDescriptionController),
              _buildFormField('赛事级别', eventLevelController),
              _buildFormField('奖项级别', awardLevelController),
              _buildFormField('赛事权重系数', eventWeightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true)),
              _buildFormField('奖项权重系数', awardWeightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true)),
              _buildFormField('基础分', baseScoreController, keyboardType: TextInputType.number),
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
              if (!mounted) return;
              try {
                final newRule = {
                  'recognizedEventId': '0',
                  'eventLevel': eventLevelController.text,
                  'eventWeight': double.tryParse(eventWeightController.text) ?? 1.0,
                  'baseScore': double.tryParse(baseScoreController.text) ?? 0.0,
                  'ruleDescription': ruleDescriptionController.text,
                  'isEditable': false,
                  'awardLevel': awardLevelController.text,
                  'awardWeight': double.tryParse(awardWeightController.text) ?? 1.0,
                };
                await ScoreRuleService.createScoreRule(newRule);
                Navigator.pop(context);
                _fetchAllScoreRules(); // 重新获取所有规则，刷新列表
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('规则创建成功')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('创建失败: ${e.toString()}')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 构建表单字段（保持不变）
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
