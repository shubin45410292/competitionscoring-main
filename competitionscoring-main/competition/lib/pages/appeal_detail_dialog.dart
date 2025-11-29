//辅导员  处理学生申诉 申诉详情页面

import 'package:flutter/material.dart';

class AppealDetailDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  // 必须声明的回调参数（用于接收处理结果输入框内容）
  final ValueChanged<String> onResultChanged;

  // 构造函数中明确标记所有参数为必填
  const AppealDetailDialog({
    super.key,
    required this.item,
    required this.onApprove,
    required this.onReject,
    required this.onResultChanged, // 关键：必须传递此参数
  });

  @override
  State<AppealDetailDialog> createState() => _AppealDetailDialogState();
}

class _AppealDetailDialogState extends State<AppealDetailDialog> {
  final TextEditingController _resultController = TextEditingController();

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('申诉详情', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // 申诉内容展示
            Text('申诉内容：${widget.item['content'] ?? '无内容'}'),
            const SizedBox(height: 16),

            // 处理结果输入框（核心）
            const Text('处理结果：', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _resultController,
              decoration: const InputDecoration(
                hintText: '请输入审核意见',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              // 实时将输入内容传递给父组件
              onChanged: (value) => widget.onResultChanged(value),
            ),
            const SizedBox(height: 20),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: widget.onReject,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('驳回'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: widget.onApprove,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('通过'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
