// 申诉对话框

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart'; // 用于选择文件

import 'package:competition/util/appeal_request.dart';

import 'package:flutter_dropzone/flutter_dropzone.dart';

import 'package:path_provider/path_provider.dart'; // 临时目录依赖

class AppealDialog extends StatefulWidget {
  // 接收外部传入的赛事材料ID（必填，从赛事详情页传递）

  final String resultId;

  const AppealDialog({
    super.key,

    required this.resultId, // 外部传入真实的赛事材料ID，替代硬编码
  });

  @override
  State<AppealDialog> createState() => _AppealDialogState();
}

class _AppealDialogState extends State<AppealDialog> {
  // 1. 修复：定义输入框控制器（管理申诉理由输入）

  final TextEditingController _appealController = TextEditingController();

  // 2. 修复：定义选中的文件变量（存储上传的附件）

  File? _selectedFile;

  // 3. 申诉类型选择（默认选中第一个，支持切换）

  String _selectedAppealType = "分级异议";

  final List<String> _appealTypeOptions = ["分级异议", "积分异议"];

  // 新增：拖拽上传控制器

  DropzoneViewController? _dropzoneController;

  @override
  void dispose() {
    // 销毁控制器，避免内存泄漏

    _appealController.dispose();

    super.dispose();
  }

  // 4. 实现文件选择逻辑（点击上传）

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,

        allowedExtensions: ['pdf', 'doc', 'jpg', 'png'],

        withData: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // 提前校验文件大小

        if (!_validateFileSize(file)) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("文件大小超过50MB限制，请重新选择")));

          return;
        }

        setState(() {
          _selectedFile = file;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("已选择文件：${result.files.single.name}")),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("文件选择失败：${e.toString().substring(0, 30)}...")),
      );
    }
  }

  // 优化文件大小校验方法，支持传入文件直接校验

  bool _validateFileSize([File? file]) {
    final targetFile = file ?? _selectedFile;

    if (targetFile == null) return true;

    final fileSizeInMB = targetFile.lengthSync() / (1024 * 1024);

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
            // 标题栏
            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(vertical: 10),

              decoration: BoxDecoration(
                color: Colors.blue[600],

                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
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

            // 新增：申诉类型选择（下拉框）
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),

              child: DropdownButtonFormField<String>(
                value: _selectedAppealType,

                items: _appealTypeOptions
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,

                        child: Text(type, style: const TextStyle(fontSize: 14)),
                      ),
                    )
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

                validator: (value) => value == null ? "请选择申诉类型" : null,
              ),
            ),

            // 申诉理由输入框（绑定控制器）
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),

              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 0.8,
                  ),

                  left: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 0.8,
                  ),

                  right: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 0.8,
                  ),

                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 0.8,
                  ), // 补充底部边框，样式统一
                ),

                borderRadius: BorderRadius.all(Radius.circular(3)),
              ),

              child: TextField(
                controller: _appealController, // 绑定控制器

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

                    fontWeight: FontWeight.w400, // 修正hint字体权重，避免过粗
                  ),

                  border: InputBorder.none,

                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            // 文件上传区域（支持点击+拖拽）
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
                onTap: _pickFile, // 点击触发文件选择

                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      style: BorderStyle.solid,
                    ),

                    borderRadius: BorderRadius.circular(6),
                  ),

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
            ),

            const SizedBox(height: 10),

            // 取消/提交按钮
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
                        // 1. 收集并校验参数

                        final appealMessage = _appealController.text.trim();

                        if (appealMessage.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("请详细描述申诉理由")),
                          );

                          return;
                        }

                        // 校验文件大小

                        if (!_validateFileSize()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("文件大小超过50MB限制，请重新选择")),
                          );

                          return;
                        }

                        // 2. 构造申诉请求参数（使用外部传入的resultId，而非硬编码）

                        final appealRequest = AppealRequest(
                          resultId: widget.resultId, // 从父组件传入真实赛事ID

                          appealType: _selectedAppealType, // 下拉选择的申诉类型

                          appealMessage: appealMessage, // 输入的申诉理由

                          attachmentFile: _selectedFile, // 选中的附件文件
                        );

                        // 3. 调用申诉接口

                        try {
                          // 显示加载中提示

                          showDialog(
                            context: context,

                            barrierDismissible: false,

                            builder: (context) =>
                                const AlertDialog(content: Text("提交中...")),
                          );

                          // 提交申诉（调用接口）

                          final response = await AppealRepository.submitAppeal(
                            appealRequest,
                          );

                          // 关闭加载框和申诉对话框

                          Navigator.pop(context); // 关闭加载框

                          Navigator.pop(context); // 关闭申诉对话框

                          // 提示提交成功

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("申诉提交成功，等待审核")),
                          );
                        } catch (e) {
                          // 打印完整错误信息

                          print('申诉提交失败详情：$e');

                          // 如果是DioException，解析更详细的信息

                          /*if (e is DioException) {


                            print('Dio错误-状态码：${e.response?.statusCode}');


                            print('Dio错误-响应数据：${e.response?.data}');


                            print('Dio错误-请求头：${e.requestOptions.headers}');


                          }*/

                          // 关闭加载框

                          Navigator.pop(context);

                          // 提示失败信息（优化错误提示，避免过长）

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "申诉提交失败：${e.toString().substring(0, 50)}...",
                              ),
                            ),
                          );
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
