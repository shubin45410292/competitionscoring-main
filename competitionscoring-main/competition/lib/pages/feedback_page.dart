import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  String _selectedAcademicYear = '2024-2025';
  String _selectedStatus = '全部';
  List<FeedbackItem> _feedbackItems = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 初始化模拟数据
    _loadFeedbackItems();
  }

  void _loadFeedbackItems() {
    // 这里应该是从API获取数据，现在使用模拟数据
    _feedbackItems = [
      FeedbackItem(
        id: '1',
        content: '文件上传失败！',
        submitTime: '2025-8-8 12:41:42',
        status: '已回复',  // 更新为已回复状态
        reply: '感谢建议，我们会在下个版本改进',
      ),
      FeedbackItem(
        id: '2',
        content: 'xxxxxxxxxx!',
        submitTime: '2025-8-7 10:30:15',
        status: '待回复',
        reply: '',
      ),
      FeedbackItem(
        id: '3',
        content: 'xxxxxxxxx!',
        submitTime: '2025-8-6 15:22:30',
        status: '待回复',
        reply: '',
      ),
      // 添加一个已回复的反馈项示例
      FeedbackItem(
        id: '4',
        content: '界面显示异常',
        submitTime: '2025-8-5 09:15:20',
        status: '已回复',
        reply: '问题已修复，请更新到最新版本',
      ),
    ];
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
      // 这里可以添加学年筛选逻辑，如果需要的话
      return true;
    }).toList();
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入反馈内容')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 1));
      
      // 添加新的反馈项
      final newFeedback = FeedbackItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _feedbackController.text.trim(),
        submitTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        status: '待回复',
        reply: '',
      );

      setState(() {
        _feedbackItems.insert(0, newFeedback);
        _feedbackController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('反馈提交成功')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('提交失败，请重试')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // 显示反馈对话框
  void _showFeedbackDialog() {
    final TextEditingController dialogController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('请描述您的问题'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: dialogController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '请输入内容',
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
                  onPressed: () {
                    dialogController.clear();
                  },
                  child: const Text('重置'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (dialogController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入反馈内容')),
                            );
                            return;
                          }

                          setStateDialog(() {
                            isSubmitting = true;
                          });

                          try {
                            // 模拟网络请求
                            await Future.delayed(const Duration(seconds: 1));
                            
                            // 添加新的反馈项
                            final newFeedback = FeedbackItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              content: dialogController.text.trim(),
                              submitTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                              status: '待回复',
                              reply: '',
                            );

                            setState(() {
                              _feedbackItems.insert(0, newFeedback);
                            });

                            // 关闭对话框
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('反馈提交成功')),
                            );
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('提交失败，请重试')),
                            );
                          } finally {
                            setStateDialog(() {
                              isSubmitting = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('问题与反馈'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // 筛选栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedAcademicYear,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: ['2024-2025', '2023-2024', '2022-2023']
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text('学年: $year'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAcademicYear = value!;
                      });
                    },
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
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 反馈列表
          Expanded(
            child: ListView.builder(
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
                        Text(
                          '申诉时间: ${item.submitTime}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 底部反馈按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _showFeedbackDialog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('反馈'),
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

class FeedbackItem {
  final String id;
  final String content;
  final String submitTime;
  final String status;
  final String reply;

  FeedbackItem({
    required this.id,
    required this.content,
    required this.submitTime,
    required this.status,
    required this.reply,
  });
}