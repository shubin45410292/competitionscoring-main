import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_home_page.dart'; // 导入 AdminHomePage

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  State<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends State<AdminFeedbackPage> {
  String _selectedYear = '全部'; // 时间筛选
  String _selectedStatus = '全部'; // 回复状态筛选
  String _selectedFeedbackType = '全部'; // 反馈类型筛选
  List<FeedbackItem> _feedbackItems = [];
  bool _isProcessing = false;

  // 反馈类型选项
  final List<String> _feedbackTypes = [
    '全部',
    '功能建议',
    'bug反馈',
    '体验问题',
    '其他反馈'
  ];

  // 日期格式化工具
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _loadFeedbackItems();
  }

  void _loadFeedbackItems() {
    // 反馈记录
    _feedbackItems = [
      FeedbackItem(
        id: '1',
        content: '文件上传失败',
        submitTime: '2025-08-08 12:41:42',
        status: '待回复',
        reply: '',
        type: 'bug反馈',
        studentId: '2023001',
      ),
      FeedbackItem(
        id: '2',
        content: '希望增加深色模式',
        submitTime: '2025-08-07 10:30:15',
        status: '已回复',
        reply: '感谢建议，我们会在下个版本改进',
        type: '功能建议',
        studentId: '2023002',
      ),
      FeedbackItem(
        id: '3',
        content: '页面加载速度太慢',
        submitTime: '2025-08-06 15:22:30',
        status: '待回复',
        reply: '',
        type: '体验问题',
        studentId: '2023003',
      ),
      FeedbackItem(
        id: '4',
        content: '界面显示异常',
        submitTime: '2024-08-05 09:15:20',
        status: '已回复',
        reply: '问题已修复，请更新至最新版本',
        type: 'bug反馈',
        studentId: '2023004',
      ),
    ];
  }

  // 日期解析容错方法
  DateTime? _parseSafeDate(String dateStr) {
    try {
      return _dateFormatter.parse(dateStr);
    } catch (e) {
      debugPrint('日期解析失败：$dateStr，错误信息：$e');
      return DateTime.now();
    }
  }

  // 根据筛选条件获取过滤后的反馈列表
  List<FeedbackItem> get _filteredFeedbackItems {
    return _feedbackItems.where((item) {
      // 状态筛选
      if (_selectedStatus != '全部') {
        bool isReplied = item.reply.isNotEmpty;
        if (_selectedStatus == '已回复' && !isReplied) return false;
        if (_selectedStatus == '待回复' && isReplied) return false;
      }
      // 时间（按年份）筛选
      if (_selectedYear != '全部') {
        final itemYear = DateTime.parse(item.submitTime).year.toString();
        if (itemYear != _selectedYear) return false;
      }
      // 反馈类型筛选
      if (_selectedFeedbackType != '全部' && item.type != _selectedFeedbackType) {
        return false;
      }

      return true;
    }).toList();
  }

  // 处理回复反馈
  void _handleReply(FeedbackItem item) {
    final TextEditingController replyController = TextEditingController(text: item.reply);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('回复反馈'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 显示反馈详情
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('学生ID: ${item.studentId}'),
                    const SizedBox(height: 8),
                    Text('反馈类型: ${item.type}'),
                    const SizedBox(height: 8),
                    Text('提交时间: ${item.submitTime}'),
                    const SizedBox(height: 8),
                    Text('反馈内容: ${item.content}'),
                  ],
                ),
              ),
              // 回复输入框
              TextField(
                controller: replyController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '请输入回复内容',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      if (replyController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请输入回复内容')),
                        );
                        return;
                      }

                      setState(() => _isProcessing = true);

                      try {
                        // 模拟网络请求
                        await Future.delayed(const Duration(seconds: 1));

                        // 更新反馈回复状态
                        setState(() {
                          final index = _feedbackItems.indexWhere((i) => i.id == item.id);
                          if (index != -1) {
                            _feedbackItems[index] = FeedbackItem(
                              id: item.id,
                              content: item.content,
                              submitTime: item.submitTime,
                              status: '已回复',
                              reply: replyController.text.trim(),
                              type: item.type,
                              studentId: item.studentId,
                            );
                          }
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('回复成功')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('回复失败，请重试')),
                        );
                      } finally {
                        setState(() => _isProcessing = false);
                      }
                    },
              child: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('提交回复'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('反馈管理'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomePage()),
            )
          },
        ),
      ),
      body: Column(
        children: [
          // 筛选栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 第一行：年份 + 状态筛选
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedYear,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: ['全部', '2025', '2024', '2023']
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text('年份: $year'),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedYear = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: ['全部', '待回复', '已回复']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text('状态: $status'),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedStatus = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 第二行：反馈类型筛选
                DropdownButtonFormField<String>(
                  value: _selectedFeedbackType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: _feedbackTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text('反馈类型: $type'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedFeedbackType = value!),
                ),
              ],
            ),
          ),
          
          // 反馈列表
          Expanded(
            child: _filteredFeedbackItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '没有找到符合条件的反馈记录',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '请尝试调整筛选条件',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredFeedbackItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredFeedbackItems[index];
                      final bool hasReply = item.reply.isNotEmpty;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题和状态标签
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.content,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // 状态标签
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: hasReply ? Colors.green.shade100 : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      hasReply ? '已回复' : '待回复',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: hasReply ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // 显示反馈类型
                              Text(
                                '反馈类型: ${item.type}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              // 学生ID
                              Text(
                                '提交学生: ${item.studentId}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              // 提交时间
                              Text(
                                '提交时间: ${item.submitTime}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              // 回复内容
                              if (hasReply)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '管理员回复: ${item.reply}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              // 回复按钮
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () => _handleReply(item),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                    ),
                                    child: Text(hasReply ? '编辑回复' : '回复'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 系统版本信息
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '系统版本v2.3.1 | 服务状态: 正常',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// FeedbackItem类
class FeedbackItem {
  final String id;
  final String content;
  final String submitTime;
  final String status;
  final String reply;
  final String type;
  final String studentId;

  FeedbackItem({
    required this.id,
    required this.content,
    required this.submitTime,
    required this.status,
    required this.reply,
    required this.type,
    required this.studentId,
  });
}