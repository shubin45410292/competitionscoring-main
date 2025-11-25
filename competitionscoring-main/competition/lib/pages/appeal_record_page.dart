// 申诉记录页面(学生端)
import 'package:flutter/material.dart';
import 'package:competition/util/http.dart';
import 'package:competition/util/token_util.dart';

class AppealRecordPage extends StatefulWidget {
  const AppealRecordPage({super.key});

  @override
  State<AppealRecordPage> createState() => _AppealRecordPageState();
}

class _AppealRecordPageState extends State<AppealRecordPage> {
  String selectedYear = '2024-2025';
  String selectedLevel = '全部';
  
  List<Map<String, dynamic>> appeals = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAppealRecords();
  }

  // 从后端加载申诉记录
  Future<void> _loadAppealRecords() async {
  setState(() {
    isLoading = true;
    hasError = false;
  });

  try {
    print('开始请求申诉记录...');
    final accessToken = await TokenUtil.getAccessToken();
    final refreshToken = await TokenUtil.getRefreshToken();
    final userId = await TokenUtil.getUserId();
    
    print('当前用户ID: $userId');
    print('AccessToken: ${accessToken != null ? "存在" : "不存在"}');
    print('RefreshToken: ${refreshToken != null ? "存在" : "不存在"}');

    final response = await get('/query/appeal/stu');
    print('请求完成，状态码: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseData = response.data;
      print('响应数据: $responseData');
      
      if (responseData['base']['code'] == 10000) {
        final items = responseData['data']['items'] as List<dynamic>;
        print('获取到 ${items.length} 条申诉记录');
        
        setState(() {
          appeals = items.map((item) {
            return _convertToDisplayData(item);
          }).toList();
        });
      } else {
        print('业务逻辑错误: ${responseData['base']['msg']}');
        setState(() {
          hasError = true;
          errorMessage = responseData['base']['msg'] ?? '加载失败';
        });
      }
    } else {
      print('HTTP错误: ${response.statusCode}');
      setState(() {
        hasError = true;
        errorMessage = '网络请求失败: ${response.statusCode}';
      });
    }
  } catch (e) {
    print('异常信息: $e');
    setState(() {
      hasError = true;
      errorMessage = '加载申诉记录失败: $e';
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  // 将后端数据转换为前端显示格式
  Map<String, dynamic> _convertToDisplayData(Map<String, dynamic> backendData) {
    // 状态映射
    String statusText;
    Color statusColor;
    
    switch (backendData['status']) {
      case 'pending':
        statusText = '待审核';
        statusColor = Colors.orange;
        break;
      case 'approved':
        statusText = '审核通过';
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusText = '审核驳回';
        statusColor = Colors.red;
        break;
      default:
        statusText = '待审核';
        statusColor = Colors.orange;
    }
    
    // 申诉类型映射
    String appealTypeText;
    switch (backendData['appeal_type']) {
      case '分级异议':
        appealTypeText = '赛事级别认定有误';
        break;
      case '积分异议':
        appealTypeText = '积分计算有误';
        break;
      default:
        appealTypeText = backendData['appeal_type'] ?? '其他异议';
    }
    
    // 时间戳转换
    String formatTime(String timestamp) {
      try {
        final time = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
        return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
      } catch (e) {
        return '未知时间';
      }
    }

    return {
      'title': '竞赛申诉', // 可以根据result_id获取具体赛事名称，这里使用通用标题
      'appealTime': formatTime(backendData['created_at']),
      'identifyInfo': '申诉ID: ${backendData['appeal_id']}',
      'content': backendData['appeal_reason'],
      'status': statusText,
      'color': statusColor,
      'appealType': backendData['appeal_type'],
      'originalData': backendData, // 保留原始数据
    };
  }

  // 刷新数据
  Future<void> _refreshData() async {
    await _loadAppealRecords();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部筛选
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown(
                  label: '学年',
                  value: selectedYear,
                  items: const ['2023-2024', '2024-2025', '2025-2026'],
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
            const SizedBox(height: 12),
            
            // 加载状态和错误处理
            if (isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('正在加载申诉记录...'),
                    ],
                  ),
                ),
              )
            else if (hasError)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('加载失败: $errorMessage', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              )
            else if (appeals.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('暂无申诉记录', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    itemCount: appeals.length,
                    itemBuilder: (context, index) {
                      final item = appeals[index];
                      return _buildAppealCard(item);
                    },
                  ),
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

  // 申诉卡片
  Widget _buildAppealCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14), 
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
          // 标题 + 状态
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['title'],
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('申诉时间：${item['appealTime']}',
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
          Text('申诉类型：${item['appealType']}',
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
          Text('申诉内容：${item['content']}',
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['status'],
                  style: TextStyle(
                      color: item['color'],
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}