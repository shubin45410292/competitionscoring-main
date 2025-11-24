//学生端：查看个人积分
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/http.dart';
import 'package:competition/util/token_util.dart';
import 'appeal_dialog.dart';

class ScoreDetailPage extends StatefulWidget {
  const ScoreDetailPage({super.key});

  @override
  State<ScoreDetailPage> createState() => _ScoreDetailPageState();
}

class _ScoreDetailPageState extends State<ScoreDetailPage> {
  String selectedYear = '2024–2025';
  String selectedLevel = '全部';

  // 存储从后端获取的积分数据
  List<Map<String, dynamic>> scoreData = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _fetchScoreData();
  }

  // 获取学生上传的材料列表
  Future<void> _fetchScoreData() async {
    try {
      String? userId = await TokenUtil.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception("未获取到用户信息，请重新登录");
      }

      Response response = await get(
        "/query/materials/stu",
        queryParameters: {
          "page_num": "1",
          "page_size": "10",
          "stu_id": userId
        },
      );

      if (response.data["base"]["code"] == 10000) {
        List<dynamic> items = response.data["data"]["items"];
        for (var item in items) {
          await _fetchScoreByEventId(item);
        }

        setState(() => _isLoading = false);
      } else {
        throw Exception("获取材料列表失败：${response.data["base"]["msg"] ?? "未知错误"}");
      }
    } catch (e) {
      setState(() {
        _loadError = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      debugPrint("获取积分数据错误：$e");
    }
  }

  // 根据event_id获取积分
  Future<void> _fetchScoreByEventId(Map<String, dynamic> materialItem) async {
    try {
      String eventId = materialItem["event_id"] ?? "";
      if (eventId.isEmpty) {
        _addScoreItem(materialItem, "0");
        return;
      }

      Response scoreResponse = await get(
        "/query/score/material",
        queryParameters: {"event_id": eventId},
      );

      if (scoreResponse.data["base"]["code"] == 10000) {
        String finalScore = scoreResponse.data["data"]["final_score"].toString();
        _addScoreItem(materialItem, finalScore);
      } else {
        _addScoreItem(materialItem, "0");
        debugPrint("获取event_id=$eventId的积分失败：${scoreResponse.data["base"]["msg"]}");
      }
    } catch (e) {
      _addScoreItem(materialItem, "0");
      debugPrint("获取积分失败：$e");
    }
  }

  // 添加数据到列表
  void _addScoreItem(Map<String, dynamic> materialItem, String score) {
    setState(() {
      scoreData.add({
        'title': materialItem["event_name"] ?? "未知赛事",
        'date': materialItem["award_time"] ?? "未知时间",
        'award': materialItem["award_level"] ?? "未知奖项",
        'level': materialItem["event_level"] ?? "未知级别",
        'material': materialItem["material_url"] ?? "",
        'organizer': materialItem["event_organizer"] ?? "未知单位",
        'status': materialItem["material_status"] ?? "审核中",
        'score': score,
        'event_id': materialItem["event_id"] ?? ""
      });
    });
  }

  // 筛选数据
  List<Map<String, dynamic>> get _filteredData {
    return scoreData.where((item) {
      bool levelMatch = selectedLevel == "全部"
          ? true
          : item["level"].toString().contains(selectedLevel);

      bool yearMatch = item["date"].toString().contains(selectedYear.split('–')[0]) ||
          item["date"].toString().contains(selectedYear.split('–')[1]);

      return levelMatch && yearMatch;
    }).toList();
  }

  // 查看详情弹窗（优化文字对齐）
  void _showDetailDialog(Map<String, dynamic> item) {
    // 根据审核状态获取对应的图标和颜色
    Widget getStatusIcon() {
      switch (item['status']) {
        case '待审核':
          return const Icon(Icons.access_time, color: Colors.orange, size: 20);
        case '已审核':
          return const Icon(Icons.check_circle, color: Colors.green, size: 20);
        case '驳回':
          return const Icon(Icons.cancel, color: Colors.red, size: 20);
        default:
          return const Icon(Icons.info_outline, color: Colors.grey, size: 20);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 弹窗标题栏
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "赛事详情",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    // 状态标签
                    Row(
                      children: [
                        getStatusIcon(),
                        const SizedBox(width: 6),
                        Text(
                          item['status'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(item['status']),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 分割线
                Container(
                  height: 1,
                  color: const Color(0xFFF5F5F5),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
                const SizedBox(height: 8),
                // 详情内容（使用Row横向布局实现对齐）
                Column(
                  children: [
                    _buildAlignedDetailItem("赛事名称", item['title']),
                    _buildAlignedDetailItem("竞赛时间", item['date']),
                    _buildAlignedDetailItem("获得奖项", item['award']),
                    _buildAlignedDetailItem("赛事级别", item['level']),
                    _buildAlignedDetailItem("举办单位", item['organizer']),
                    _buildAlignedDetailItem("计算积分", item['score'], isHighlight: true),
                    _buildAlignedDetailItem("材料链接", item['material'], isUrl: true),
                  ],
                ),
                const SizedBox(height: 24),
                // 底部按钮
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "关闭",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 对齐版本的详情项组件（核心优化）
  Widget _buildAlignedDetailItem(String label, String value, {bool isUrl = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 顶部对齐
        children: [
          // 标签部分：固定宽度 + 右对齐 + 统一样式
          SizedBox(
            width: 85, // 固定标签宽度，确保所有冒号对齐
            child: Text(
              "$label：",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
                //textAlign: TextAlign.right, // 标签右对齐
              ),
            ),
          ),
          const SizedBox(width: 12), // 标签与内容间距固定
          // 内容部分：自适应宽度 + 左对齐
          Expanded(
            child: isUrl
                ? // 链接样式
            GestureDetector(
              onTap: () {
                if (value.isNotEmpty) {
                  debugPrint("打开链接：$value");
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        value.isEmpty ? "无" : value,
                        style: TextStyle(
                          fontSize: 13,
                          color: value.isEmpty ? const Color(0xFF999999) : const Color(0xFF2196F3),
                          decoration: value.isNotEmpty ? TextDecoration.underline : TextDecoration.none,
                          decorationColor: const Color(0xFF2196F3),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    if (value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: const Icon(Icons.launch, size: 16, color: Color(0xFF2196F3)),
                      ),
                  ],
                ),
              ),
            )
                : // 普通文本样式
            Text(
              value.isEmpty ? "无" : value,
              style: TextStyle(
                fontSize: 15,
                color: isHighlight
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF333333),
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case '待审核':
        return Colors.orange;
      case '已审核':
        return Colors.green;
      case '驳回':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          '个人积分明细',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部筛选栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown(
                  label: '学年',
                  value: selectedYear,
                  items: const ['2023–2024', '2024–2025', '2025–2026'],
                  onChanged: (value) => setState(() => selectedYear = value!),
                ),
                _buildDropdown(
                  label: '赛事级别',
                  value: selectedLevel,
                  items: const ['全部', '国家级', '省级', '校级'],
                  onChanged: (value) => setState(() => selectedLevel = value!),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 表头
            _buildTableHeader(),

            // 加载状态展示
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_loadError != null)
              Expanded(
                child: Center(
                  child: Text(
                    "加载失败：$_loadError",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              )
            else if (_filteredData.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      "暂无积分数据",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final item = _filteredData[index];
                      return _buildScoreRow(item);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // 下拉框组件
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Text('$label：', style: const TextStyle(fontSize: 15)),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items
                  .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 15)),
              ))
                  .toList(),
              onChanged: onChanged,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  // 表头
  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(
              flex: 5,
              child: Text(
                '赛事名称',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '识别信息',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '状态',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '积分',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '操作',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 每一行积分信息
  Widget _buildScoreRow(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              item['title'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  item['date'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Text(
                  item['award'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item['status'],
              style: TextStyle(
                color: _getStatusColor(item['status']),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item['score'],
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 查看按钮
                GestureDetector(
                  onTap: () => _showDetailDialog(item),
                  child: Text(
                    '查看',
                    style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 3),
                // 申诉按钮
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AppealDialog(
                        // eventId: item['event_id'],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '申诉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
