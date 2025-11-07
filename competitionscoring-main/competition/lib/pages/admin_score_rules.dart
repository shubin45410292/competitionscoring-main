// 积分权重规则管理页面(管理员端)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScoreRulesPage extends StatefulWidget {
  const ScoreRulesPage({super.key});

  @override
  State<ScoreRulesPage> createState() => _ScoreRulesPageState();
}

// 积分权重规则数据模型
class ScoreRule {
  final int id;
  final int recognizedEventId;
  final String eventLevel;
  final double eventWeight;
  final int baseScore;
  final String ruleDescription;
  final int someField; // 占位字段，根据实际需求调整
  final String awardLevel;
  final double awardWeight;

  ScoreRule({
    required this.id,
    required this.recognizedEventId,
    required this.eventLevel,
    required this.eventWeight,
    required this.baseScore,
    required this.ruleDescription,
    required this.someField,
    required this.awardLevel,
    required this.awardWeight,
  });

  // 是否为通用规则
  bool get isGeneralRule => recognizedEventId == 0;

  // 获取规则名称
  String get ruleName {
    if (isGeneralRule) {
      return ruleDescription;
    } else {
      return ruleDescription;
    }
  }
}

class _ScoreRulesPageState extends State<ScoreRulesPage> {
  int currentPage = 1;
  final int itemsPerPage = 5;
  final TextEditingController _searchController = TextEditingController();
  String activeTab = '通用规则'; // 默认显示通用规则
  late String formattedDate;
  List<ScoreRule> allRules = [];
  List<ScoreRule> filteredRules = [];
  List<ScoreRule> currentPageRules = [];

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());
    // 初始化规则数据
    _initializeRules();
  }

  // 初始化规则数据
  void _initializeRules() {
    allRules = [
      // 通用规则
      ScoreRule(recognizedEventId: 0, eventLevel: '国家级', eventWeight: 1.00, baseScore: 100, ruleDescription: '国家级赛事一等奖通用规则', id: 1, awardLevel: '一等奖', awardWeight: 1.00, someField: 0),
      ScoreRule(recognizedEventId: 0, eventLevel: '国家级', eventWeight: 1.00, baseScore: 80, ruleDescription: '国家级赛事二等奖通用规则', id: 2, awardLevel: '二等奖', awardWeight: 0.80, someField: 0),
      ScoreRule(recognizedEventId: 0, eventLevel: '国家级', eventWeight: 1.00, baseScore: 60, ruleDescription: '国家级赛事三等奖通用规则', id: 3, awardLevel: '三等奖', awardWeight: 0.60, someField: 0),
      ScoreRule(recognizedEventId: 0, eventLevel: '省级', eventWeight: 0.80, baseScore: 80, ruleDescription: '省级赛事一等奖通用规则', id: 4, awardLevel: '一等奖', awardWeight: 1.00, someField: 0),
      ScoreRule(recognizedEventId: 0, eventLevel: '省级', eventWeight: 0.80, baseScore: 60, ruleDescription: '省级赛事二等奖通用规则', id: 5, awardLevel: '二等奖', awardWeight: 0.80, someField: 0),
      ScoreRule(recognizedEventId: 0, eventLevel: '省级', eventWeight: 0.80, baseScore: 40, ruleDescription: '省级赛事三等奖通用规则', id: 6, awardLevel: '三等奖', awardWeight: 0.60, someField: 0),
      ScoreRule(recognizedEventId: 0, eventLevel: '校级', eventWeight: 0.60, baseScore: 60, ruleDescription: '校级赛事一等奖通用规则', id: 7, awardLevel: '一等奖', awardWeight: 1.00, someField: 0),
      ScoreRule(recognizedEventId: 0, eventLevel: '校级', eventWeight: 0.60, baseScore: 40, ruleDescription: '校级赛事二等奖通用规则', id: 8, awardLevel: '二等奖', awardWeight: 0.80, someField: 0),
      ScoreRule(recognizedEventId: 0, eventLevel: '校级', eventWeight: 0.60, baseScore: 20, ruleDescription: '校级赛事三等奖通用规则', id: 9, awardLevel: '三等奖', awardWeight: 0.60, someField: 0),
      
      // 特殊规则
      ScoreRule(recognizedEventId: 10, eventLevel: '国家级', eventWeight: 1.20, baseScore: 120, ruleDescription: 'ACM国际大学生程序设计竞赛特殊规则', id: 10, awardLevel: '一等奖', awardWeight: 1.00, someField: 0),
      ScoreRule(recognizedEventId: 10, eventLevel: '国家级', eventWeight: 1.20, baseScore: 100, ruleDescription: 'ACM国际大学生程序设计竞赛特殊规则', id: 11, awardLevel: '二等奖', awardWeight: 0.80, someField: 0),
      ScoreRule(recognizedEventId: 10, eventLevel: '国家级', eventWeight: 1.20, baseScore: 80, ruleDescription: 'ACM国际大学生程序设计竞赛特殊规则', id: 12, awardLevel: '三等奖', awardWeight: 0.60, someField: 0),
      ScoreRule(recognizedEventId: 11, eventLevel: '国家级', eventWeight: 1.15, baseScore: 115, ruleDescription: '数学建模竞赛特殊规则', id: 13, awardLevel: '一等奖', awardWeight: 1.00, someField: 0),
      ScoreRule(recognizedEventId: 11, eventLevel: '国家级', eventWeight: 1.15, baseScore: 90, ruleDescription: '数学建模竞赛特殊规则', id: 14, awardLevel: '二等奖', awardWeight: 0.80, someField: 0),
      ScoreRule(recognizedEventId: 11, eventLevel: '国家级', eventWeight: 1.15, baseScore: 70, ruleDescription: '数学建模竞赛特殊规则', id: 15, awardLevel: '三等奖', awardWeight: 0.60, someField: 0),
      ScoreRule(recognizedEventId: 12, eventLevel: '省级', eventWeight: 0.90, baseScore: 90, ruleDescription: '省级编程竞赛特殊规则', id: 16, awardLevel: '一等奖', awardWeight: 1.00, someField: 0),
      ScoreRule(recognizedEventId: 12, eventLevel: '省级', eventWeight: 0.90, baseScore: 70, ruleDescription: '省级编程竞赛特殊规则', id: 17, awardLevel: '二等奖', awardWeight: 0.80, someField: 0),
      ScoreRule(recognizedEventId: 12, eventLevel: '省级', eventWeight: 0.90, baseScore: 50, ruleDescription: '省级编程竞赛特殊规则', id: 18, awardLevel: '三等奖', awardWeight: 0.60, someField: 0),
    ];
    
    _filterRules();
  }

  // 过滤规则
  void _filterRules() {
    setState(() {
      String searchText = _searchController.text.toLowerCase();
      
      // 根据当前标签和搜索文本过滤规则
      filteredRules = allRules.where((rule) {
        bool matchesTab = activeTab == '通用规则' ? rule.isGeneralRule : !rule.isGeneralRule;
        bool matchesSearch = rule.ruleName.toLowerCase().contains(searchText) ||
                           rule.eventLevel.toLowerCase().contains(searchText) ||
                           rule.awardLevel.toLowerCase().contains(searchText);
        return matchesTab && matchesSearch;
      }).toList();
      
      // 重置到第一页
      currentPage = 1;
      _calculateCurrentPageRules();
    });
  }

  // 计算当前页显示的规则
  void _calculateCurrentPageRules() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    endIndex = endIndex > filteredRules.length ? filteredRules.length : endIndex;
    
    currentPageRules = filteredRules.sublist(startIndex, endIndex);
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
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
                  hintText: '搜索规则',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 标签切换
            SizedBox(width: double.infinity, child: _buildTabButtons()),

            const SizedBox(height: 16),

            // 规则列表
            Expanded(
              child: currentPageRules.isEmpty
                  ? const Center(child: Text('暂无规则数据'))
                  : ListView.builder(
                      itemCount: currentPageRules.length,
                      itemBuilder: (context, index) {
                        return _buildRuleCard(currentPageRules[index]);
                      },
                    ),
            ),

            const SizedBox(height: 16),

              // 新建按钮
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _showCreateRuleDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('新建', style: TextStyle(fontSize: 14)),
              ),
            ),

            const SizedBox(height: 16),

            // 分页控件
            _buildPagination(),

            const SizedBox(height: 10),

            // 底部状态栏
            Text(
              '$formattedDate  |  系统版本v2.3.1  |  服务状态：正常',
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 标签切换按钮
  Widget _buildTabButtons() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                activeTab = '通用规则';
                _filterRules();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: activeTab == '通用规则' ? Colors.blue[600] : Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '通用规则',
              style: TextStyle(
                color: activeTab == '通用规则' ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                activeTab = '特殊规则';
                _filterRules();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: activeTab == '特殊规则' ? Colors.blue[600] : Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '特殊规则',
              style: TextStyle(
                color: activeTab == '特殊规则' ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 规则卡片
  Widget _buildRuleCard(ScoreRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
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
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        _showEditRuleDialog(rule);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        _showDeleteConfirmationDialog(rule);
                      },
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
            Text('奖项权重系数: ${rule.awardWeight}'),
            const SizedBox(height: 4),
            Text('基础分: ${rule.baseScore}'),
          ],
        ),
      ),
    );
  }

  // 分页控件
  Widget _buildPagination() {
    int totalPages = (filteredRules.length + itemsPerPage - 1) ~/ itemsPerPage;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1 ? () {
            setState(() {
              currentPage--;
              _calculateCurrentPageRules();
            });
          } : null,
          disabledColor: Colors.grey[300],
        ),
        Text('$currentPage/$totalPages'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages ? () {
            setState(() {
              currentPage++;
              _calculateCurrentPageRules();
            });
          } : null,
          disabledColor: Colors.grey[300],
        ),
      ],
    );
  }

  // 显示编辑规则对话框
  void _showEditRuleDialog(ScoreRule rule) {
    final TextEditingController _eventLevelController = TextEditingController(text: rule.eventLevel);
    final TextEditingController _awardLevelController = TextEditingController(text: rule.awardLevel);
    final TextEditingController _eventWeightController = TextEditingController(text: rule.eventWeight.toString());
    final TextEditingController _awardWeightController = TextEditingController(text: rule.awardWeight.toString());
    final TextEditingController _baseScoreController = TextEditingController(text: rule.baseScore.toString());
    final TextEditingController _ruleDescriptionController = TextEditingController(text: rule.ruleDescription);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑规则'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormField('规则描述', _ruleDescriptionController),
                _buildFormField('赛事级别', _eventLevelController),
                _buildFormField('奖项级别', _awardLevelController),
                _buildFormField('赛事权重系数', _eventWeightController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                _buildFormField('奖项权重系数', _awardWeightController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                _buildFormField('基础分', _baseScoreController, keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 保存编辑逻辑
                setState(() {
                  int index = allRules.indexWhere((r) => r.id == rule.id);
                  if (index != -1) {
                    allRules[index] = ScoreRule(
                      id: rule.id,
                      recognizedEventId: rule.recognizedEventId,
                      eventLevel: _eventLevelController.text,
                      eventWeight: double.tryParse(_eventWeightController.text) ?? rule.eventWeight,
                      baseScore: int.tryParse(_baseScoreController.text) ?? rule.baseScore,
                      ruleDescription: _ruleDescriptionController.text,
                      someField: rule.someField,
                      awardLevel: _awardLevelController.text,
                      awardWeight: double.tryParse(_awardWeightController.text) ?? rule.awardWeight,
                    );
                    _filterRules();
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('规则已更新')),
                );
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmationDialog(ScoreRule rule) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除规则 "${rule.ruleName}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  allRules.remove(rule);
                  _filterRules();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('规则已删除')),
                );
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  // 显示新建规则对话框
  void _showCreateRuleDialog() {
    final TextEditingController _eventLevelController = TextEditingController();
    final TextEditingController _awardLevelController = TextEditingController();
    final TextEditingController _eventWeightController = TextEditingController(text: '1.0');
    final TextEditingController _awardWeightController = TextEditingController(text: '1.0');
    final TextEditingController _baseScoreController = TextEditingController();
    final TextEditingController _ruleDescriptionController = TextEditingController();
    final isGeneral = activeTab == '通用规则';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新建${activeTab}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormField('规则描述', _ruleDescriptionController),
                _buildFormField('赛事级别', _eventLevelController),
                _buildFormField('奖项级别', _awardLevelController),
                _buildFormField('赛事权重系数', _eventWeightController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                _buildFormField('奖项权重系数', _awardWeightController, keyboardType: TextInputType.numberWithOptions(decimal: true)),
                _buildFormField('基础分', _baseScoreController, keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                // 保存新建规则逻辑
                setState(() {
                  // 生成新ID
                  int newId = allRules.isNotEmpty ? allRules.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1 : 1;
                  
                  allRules.add(ScoreRule(
                    id: newId,
                    recognizedEventId: isGeneral ? 0 : (newId % 3) + 10, // 简单逻辑生成特殊规则ID
                    eventLevel: _eventLevelController.text,
                    eventWeight: double.tryParse(_eventWeightController.text) ?? 1.0,
                    baseScore: int.tryParse(_baseScoreController.text) ?? 0,
                    ruleDescription: _ruleDescriptionController.text,
                    someField: 0,
                    awardLevel: _awardLevelController.text,
                    awardWeight: double.tryParse(_awardWeightController.text) ?? 1.0,
                  ));
                  _filterRules();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('规则已新建')),
                );
              },
              child: const Text('保存'),
            ),
          ],
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