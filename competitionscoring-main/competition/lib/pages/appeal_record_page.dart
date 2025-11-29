// 申诉记录页面(学生端)
import 'package:flutter/material.dart';
import 'package:competition/util/http.dart'; // 导入你的HTTP封装
import 'dart:convert';

class AppealRecordPage extends StatefulWidget {
  const AppealRecordPage({super.key});

  @override
  State<AppealRecordPage> createState() => _AppealRecordPageState();
}

class _AppealRecordPageState extends State<AppealRecordPage> {
  String selectedYear = '2024–2025';
  String selectedLevel = '全部';

  List<Map<String, dynamic>> appeals = [];
  bool isLoading = true;
  String errorMessage = '';

  // 状态映射：后端状态 -> 前端显示文本和颜色
  Map<String, Map<String, dynamic>> statusMap = {
    'pending': {'text': '待审核', 'color': Colors.orange},
    'approved': {'text': '审核通过', 'color': Colors.green},
    'rejected': {'text': '审核驳回', 'color': Colors.red},
  };

  @override
  void initState() {
    super.initState();
    _fetchAppealRecords(); // 初始化时请求数据
  }

  // 格式化时间戳（后端返回的是秒级时间戳）
  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty || timestamp == '0') return '未知时间';
    try {
      final int seconds = int.parse(timestamp);
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return '${date.year}–${date.month.toString().padLeft(2, '0')}–${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '时间格式错误';
    }
  }

  // 从后端获取申诉记录
  Future<void> _fetchAppealRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 调用后端接口（无需参数）
      final response = await get('/query/appeal/stu');

      // 解析响应数据
      if (response.data['base']['code'] == 10000) {
        final List<dynamic> items = response.data['data']['items'];
        setState(() {
          appeals = items.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } else {
        throw Exception(response.data['base']['msg'] ?? '获取申诉记录失败');
      }
    } catch (e) {
      setState(() {
        errorMessage = '加载失败: ${e.toString()}';
      });
      print('获取申诉记录错误: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text('申诉记录',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部筛选（当前仅做展示，可根据需求对接后端筛选）
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     _buildDropdown(
            //       label: '学年',
            //       value: selectedYear,
            //       items: const ['2023–2024', '2024–2025', '2025–2026'],
            //       onChanged: (value) => setState(() => selectedYear = value!),
            //     ),
            //     _buildDropdown(
            //       label: '赛事级别',
            //       value: selectedLevel,
            //       items: const ['全部', '国家级', '省级', '校级'],
            //       onChanged: (value) => setState(() => selectedLevel = value!),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 12),

            // 加载状态、错误状态、空数据状态展示
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator(color: Colors.blue)),
              )
            else if (errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              )
            else if (appeals.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      '暂无申诉记录',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: appeals.length,
                    itemBuilder: (context, index) {
                      final item = appeals[index];
                      return _buildAppealCard(item);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // 下拉选择框组件
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
            ),
          ),
        ),
      ],
    );
  }

  // 申诉卡片（根据审核状态展示不同内容）
  Widget _buildAppealCard(Map<String, dynamic> item) {
    final String status = item['status'] ?? 'pending';
    final bool isPending = status == 'pending'; // 是否未审核
    final statusConfig = statusMap[status] ?? statusMap['pending']!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题（申诉类型）+ 状态
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item['appeal_type']} - ${item['event_name']}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusConfig['color'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusConfig['text'],
                  style: TextStyle(
                      color: statusConfig['color'],
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 基础信息（未审核和已审核都展示）
          _buildInfoRow('奖项级别', item['award_level'] ?? '无'),
          _buildInfoRow('申诉内容', item['appeal_reason'] ?? '无'),
          _buildInfoRow('当前积分', '${item['final_score'] ?? 0.0}'),
          _buildInfoRow('申诉时间', _formatTimestamp(item['created_at'] ?? '0')),

          // 已审核的额外展示：处理结果
          if (!isPending) ...[
            const SizedBox(height: 8),
            _buildInfoRow('处理结果', item['handleResult'] ?? '无'),
            _buildInfoRow('处理时间', _formatTimestamp(item['handleTime'] ?? '0')),
          ],
        ],
      ),
    );
  }

  // 信息行组件（统一样式）
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label：',
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
