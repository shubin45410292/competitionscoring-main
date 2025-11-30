import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:competition/util/appeal_request.dart';
import 'package:dio/dio.dart';

class AppealDialog extends StatefulWidget {
  final String resultId;

  const AppealDialog({
    super.key,
    required this.resultId,
  });

  @override
  State<AppealDialog> createState() => _AppealDialogState();
}

class _AppealDialogState extends State<AppealDialog> {
  final TextEditingController _appealController = TextEditingController();
  File? _selectedFile;
  String _selectedAppealType = "分级异议";
  final List<String> _appealTypeOptions = ["分级异议", "积分异议"];

  @override
  void dispose() {
    _appealController.dispose();
    super.dispose();
  }

  // 补充：定义显示SnackBar的方法（之前遗漏导致报错）
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'jpg', 'png'],
        withData: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // if (!_validateFileSize(file)) {
        //   _showSnackBar("文件大小超过50MB限制，请重新选择"); // 使用定义的方法
        //   return;
        // }

        setState(() {
          _selectedFile = file;
          _showSnackBar("已选择文件：${result.files.single.name}"); // 使用定义的方法
        });
      }
    } catch (e) {
      _showSnackBar("文件选择失败：${e.toString().substring(0, 30)}..."); // 使用定义的方法
    }
  }

  bool _validateFileSize() {
    if (_selectedFile == null) return true;
    final fileSizeInMB = _selectedFile!.lengthSync() / (1024 * 1024);
    return fileSizeInMB <= 50;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: const Center(
                child: Text(
                  '申诉申请',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 申诉类型选择
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedAppealType,
                items: _appealTypeOptions
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type, style: const TextStyle(fontSize: 14)),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAppealType = value);
                  }
                },
                decoration: InputDecoration(
                  labelText: '申诉类型',
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),

            // 申诉理由输入
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 0.8,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(3)),
              ),
              child: TextField(
                controller: _appealController,
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: '请详细描述申诉理由（如赛事级别认定有误、积分计算错误等）...',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            // 文件上传区域
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: GestureDetector(
                onTap: _pickFile,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: Colors.blue[800],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '拖拽文件至此处或点击',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: const Text(
                        '支持 PDF, DOC, JPG, PNG 格式，单个文件不超过 50MB',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (_selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '已选文件：${_selectedFile!.path.split('/').last}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 操作按钮
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        '取消',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final appealMessage = _appealController.text.trim();
                        if (appealMessage.isEmpty) {
                          _showSnackBar("请详细描述申诉理由"); // 使用定义的方法
                          return;
                        }

                        if (!_validateFileSize()) {
                          _showSnackBar("文件大小超过50MB限制，请重新选择"); // 使用定义的方法
                          return;
                        }

                        final appealRequest = AppealRequest(
                          resultId: widget.resultId,
                          appealType: _selectedAppealType,
                          appealMessage: appealMessage,
                          attachmentFile: _selectedFile,
                        );

                        try {
                          // 显示加载对话框
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const AlertDialog(
                              content: Row(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 16),
                                  Text("提交中..."),
                                ],
                              ),
                            ),
                          );

                          final response = await AppealRepository.submitAppeal(appealRequest);

                          // 关闭加载对话框和当前弹窗
                          Navigator.pop(context);
                          Navigator.pop(context);
                          _showSnackBar("申诉提交成功，等待审核"); // 使用定义的方法
                        } catch (e) {
                          // 关闭加载对话框
                          Navigator.pop(context);

                          // 终极错误匹配逻辑：无视异常类型，直接检测字符串中的40017
                          String errorString = e.toString();
                          String errorMsg;

                          if (errorString.contains('code: 40017')) {
                            errorMsg = "该材料已申诉过，请勿重复申诉";
                          } else {
                            errorMsg = "申诉提交失败，请稍后重试";
                          }

                          _showSnackBar(errorMsg); // 使用定义的方法
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        '提交申诉',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
