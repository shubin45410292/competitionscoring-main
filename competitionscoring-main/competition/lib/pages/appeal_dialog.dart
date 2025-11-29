// 辅导员 处理学生申诉 申诉详情页面
import 'package:flutter/material.dart';
import 'package:competition/util/http.dart'; // 导入你的HTTP工具类
import 'package:dio/dio.dart'; // 导入dio包以使用FormData

class AppealDetailDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final String eventId;
  final String resultId;
  final String appealId;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final ValueChanged<String> onResultChanged;

  const AppealDetailDialog({
    super.key,
    required this.item,
    required this.eventId,
    required this.resultId,
    required this.appealId,
    required this.onApprove,
    required this.onReject,
    required this.onResultChanged,
  });

  @override
  State<AppealDetailDialog> createState() => _AppealDetailDialogState();
}

class _AppealDetailDialogState extends State<AppealDetailDialog> {
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _eventLevelController = TextEditingController();
  final TextEditingController _awardLevelController = TextEditingController();

  // 判断是否为积分异议
  bool get isScoreAppeal => widget.item['title'] == '积分异议';

  // 判断是否为分级异议
  bool get isLevelAppeal => widget.item['title'] == '分级异议';

  @override
  void dispose() {
    _resultController.dispose();
    _scoreController.dispose();
    _eventLevelController.dispose();
    _awardLevelController.dispose();
    super.dispose();
  }

  // 提交积分修改请求
  Future<void> _submitScoreUpdate() async {
    if (_scoreController.text.isEmpty) {
      _showSnackBar('请输入更改后的积分', type: 'warning');
      return;
    }

    try {
      // 创建表单数据
      final formData = FormData.fromMap({
        'result_id': widget.resultId,
        'score': int.parse(_scoreController.text),
      });

      // 调用积分修改接口
      final response = await postFormData('/update/score/id', formData: formData);

      if (response.data['base']['code'] == 10000) {
        _showSnackBar('积分修改成功', type: 'success');
        widget.onResultChanged(_resultController.text);
        widget.onApprove(); // 触发审核通过回调
      } else {
        _showSnackBar('修改失败: ${response.data['base']['msg'] ?? '未知错误'}', type: 'error');
      }
    } catch (e) {
      _showSnackBar('操作失败: ${e.toString()}', type: 'error');
      print('积分修改错误: $e');
    }
  }

  // 提交赛事级别和奖项级别修改请求
  Future<void> _submitLevelUpdate() async {
    if (_eventLevelController.text.isEmpty) {
      _showSnackBar('请输入赛事级别', type: 'warning');
      return;
    }
    if (_awardLevelController.text.isEmpty) {
      _showSnackBar('请输入奖项级别', type: 'warning');
      return;
    }

    try {
      // 创建表单数据
      final formData = FormData.fromMap({
        'event_id': widget.eventId,
        'event_level': _eventLevelController.text,
        'award_level': _awardLevelController.text,
      });

      // 调用级别修改接口
      final response = await postFormData('/update/event/level', formData: formData);

      if (response.data['base']['code'] == 10000) {
        _showSnackBar('级别修改成功', type: 'success');
        widget.onResultChanged(_resultController.text);
        widget.onApprove(); // 触发审核通过回调
      } else {
        _showSnackBar('修改失败: ${response.data['base']['msg'] ?? '未知错误'}', type: 'error');
      }
    } catch (e) {
      _showSnackBar('操作失败: ${e.toString()}', type: 'error');
      print('级别修改错误: $e');
    }
  }

  // 显示提示信息（带类型区分）
  void _showSnackBar(String message, {String type = 'info'}) {
    Color backgroundColor = Colors.grey[700]!;
    if (type == 'success') backgroundColor = const Color(0xFF4CAF50);
    if (type == 'error') backgroundColor = const Color(0xFFF44336);
    if (type == 'warning') backgroundColor = const Color(0xFFFF9800);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // 构建输入框组件（通用）
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white, // 白底
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
      elevation: 10,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区域（带底部边框）
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.item['title']}处理',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: Colors.grey.shade100,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 申诉内容展示（卡片式）
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '申诉内容',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item['appeal_reason'] ?? '无内容',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.4,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 不同类型的申诉显示不同的表单
            if (isScoreAppeal) ...[
              // 积分异议表单
              _buildTextField(
                controller: _scoreController,
                label: '更改后的积分',
                hintText: '请输入新积分（数字）',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
            ] else if (isLevelAppeal) ...[
              // 分级异议表单
              _buildTextField(
                controller: _eventLevelController,
                label: '赛事级别',
                hintText: '例如：国家级、省级、校级',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _awardLevelController,
                label: '奖项级别',
                hintText: '例如：特等奖、一等奖、二等奖',
              ),
              const SizedBox(height: 20),
            ],

            // 处理结果输入框（高度更高，适合多行文本）
            _buildTextField(
              controller: _resultController,
              label: '处理结果/审核意见',
              hintText: '请输入审核意见（将同步至学生端）',
            ),
            const SizedBox(height: 8),
            const Text(
              '注：请详细说明处理依据和结果',
              style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
            const SizedBox(height: 24),

            // 操作按钮区域（优化布局和样式）
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 取消按钮（灰色边框）
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    '取消',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),

                // 驳回按钮（红色）
                ElevatedButton(
                  onPressed: widget.onReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF44336),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '驳回',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),

                // 通过并修改按钮（绿色）
                ElevatedButton(
                  onPressed: isScoreAppeal ? _submitScoreUpdate : _submitLevelUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '通过并修改',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
