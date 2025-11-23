import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart'; // 用于选择图片
import 'package:file_picker/file_picker.dart'; // 用于选择文件
import 'dart:io';
import 'package:competition/util/http.dart';


class UploadFileDialog extends StatefulWidget {
  const UploadFileDialog({super.key});

  @override
  State<UploadFileDialog> createState() => _UploadFileDialogState();
}

class _UploadFileDialogState extends State<UploadFileDialog> {
  int selectedTab = 0; // 0 = 手动输入，1 = 上传文件

  // 上传文件队列（存储文件路径和信息）
  final List<Map<String, dynamic>> _fileQueue = [
    // {"name": "xxx交通.pdf", "date": "2023/09/01", "file": null},
    // {"name": "xxx奖项.pdf", "date": "2023/09/02", "file": null},
    // {"name": "xxx资质.doc", "date": "2023/08/10", "file": null},
  ];

  // 赛事信息选项
  final List<String> _competitionNames = [
    "全国大学生机械创新设计大赛",
    "全国大学生等离子体科技创新竞赛",
    "全国大学生xxxxxx",
    "全国xxxxxxx",
  ];
  final List<String> _awardLevels = [
    "国家级一等奖", "国家级二等奖", "国家级三等奖", "省级一等奖", "省级二等奖"
  ];
  final List<String> _competitionDates = [
    "2025年5月", "2025年6月", "2025年7月", "2025年8月"
  ];
  final List<String> _organizer = [
    "2025年5月", "2025年6月", "2025年7月", "2025年8月"
  ];

  // 选中的值
  // 暂时不用，可能用于未来手动上传开发
  String? _selectedCompetition;
  String? _selectedAward;
  String? _selectedDate;
  String? _selectedOrganizer;

  // 上传状态
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedCompetition = _competitionNames.isNotEmpty ? _competitionNames[0] : null;
    _selectedAward = _awardLevels.isNotEmpty ? _awardLevels[0] : null;
    _selectedDate = _competitionDates.isNotEmpty ? _competitionDates[0] : null;
    _selectedOrganizer = _organizer.isNotEmpty ? _organizer[0] : null;
  }

  // 选择文件并添加到队列
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'], // 支持的文件类型
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;
      String date = DateTime.now().toString().split(' ')[0].replaceAll('-', '/');

      setState(() {
        _fileQueue.add({
          "name": fileName,
          "date": date,
          "file": file, // 存储文件对象用于上传
        });
      });
    }
  }

  // 提交上传（根据当前标签页选择不同上传方式）
  Future<void> _submitUpload() async {
    if (_fileQueue.isEmpty) {
      _showSnackBar("上传队列为空，请添加文件");
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. 上传文件方式（表单为form-data）
      if (selectedTab == 1) {
        for (var fileItem in _fileQueue) {
          File? file = fileItem["file"];
          if (file == null) continue;

          // 构建form-data表单
          FormData formData = FormData.fromMap({
            "file": await MultipartFile.fromFile(
              file.path,
              filename: fileItem["name"], // 保持原文件名
            ),
          });

          // 调用后端接口（完整路径：/update/materials/file）
          Response response = await dio.post(
            "/update/materials/file",
            data: formData,
            options: Options(
              contentType: "multipart/form-data", // 文件上传必须指定此类型
            ),
          );

          // 处理响应
          if (response.data["base"]["code"] == 10000) {
            String eventId = response.data["event_id"];
            _showSnackBar("文件 ${fileItem["name"]} 上传成功，event_id: $eventId");
          } else {
            throw Exception("上传失败：${response.data["base"]["msg"] ?? "未知错误"}");
          }
        }
      }
      // 2. 手动输入方式（可根据实际需求扩展）
      else {
        // 这里可以添加手动输入表单的提交逻辑
        _showSnackBar("手动输入信息已记录，可结合文件上传接口扩展");
      }

      // 上传成功后清空队列并关闭对话框
      setState(() => _fileQueue.clear());
      Navigator.pop(context);

    } catch (e) {
      _showSnackBar("上传失败：${e.toString().replaceAll('Exception: ', '')}");
      print("上传错误：$e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 显示提示信息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择上传方式',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 14),

              // 顶部切换按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //_buildTabButton('手动输入', 0),
                  _buildTabButton('上传文件', 0),
                ],
              ),

              const SizedBox(height: 20),

              // 切换显示不同表单
              // if (selectedTab == 0)
              //   _buildManualInputForm()
              // else
                _buildFileUploadForm(),

              const SizedBox(height: 16),
              Text(
                '上传队列 (${_fileQueue.length})',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 12),

              // 上传队列列表
              ..._fileQueue.map((file) => _buildFileItem(file)).toList(),

              const SizedBox(height: 20),

              // 底部按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _isUploading ? null : () {
                      setState(() {
                        _fileQueue.clear();
                        // _selectedCompetition = _competitionNames.isNotEmpty ? _competitionNames[0] : null;
                        // _selectedAward = _awardLevels.isNotEmpty ? _awardLevels[0] : null;
                        // _selectedDate = _competitionDates.isNotEmpty ? _competitionDates[0] : null;
                        // _selectedOrganizer = _organizer.isNotEmpty ? _organizer[0] : null;
                      });
                    },
                    child: const Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _submitUpload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                    ),
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('上传'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 顶部 tab 切换按钮
  Widget _buildTabButton(String label, int index) {
    final bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue[600]!),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 手动输入表单
  // Widget _buildManualInputForm() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       DropdownButtonFormField<String>(
  //         value: _selectedCompetition,
  //         decoration: const InputDecoration(
  //           labelText: '竞赛名称',
  //           border: OutlineInputBorder(),
  //         ),
  //         items: _competitionNames
  //             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
  //             .toList(),
  //         onChanged: (v) => setState(() => _selectedCompetition = v),
  //       ),
  //       const SizedBox(height: 16),
  //
  //       DropdownButtonFormField<String>(
  //         value: _selectedAward,
  //         decoration: const InputDecoration(
  //           labelText: '获得奖项',
  //           border: OutlineInputBorder(),
  //         ),
  //         items: _awardLevels
  //             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
  //             .toList(),
  //         onChanged: (v) => setState(() => _selectedAward = v),
  //       ),
  //       const SizedBox(height: 16),
  //
  //       DropdownButtonFormField<String>(
  //         value: _selectedDate,
  //         decoration: const InputDecoration(
  //           labelText: '竞赛时间',
  //           border: OutlineInputBorder(),
  //         ),
  //         items: _competitionDates
  //             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
  //             .toList(),
  //         onChanged: (v) => setState(() => _selectedDate = v),
  //       ),
  //       const SizedBox(height: 16),
  //
  //       DropdownButtonFormField<String>(
  //         value: _selectedOrganizer,
  //         decoration: const InputDecoration(
  //           labelText: '举办单位',
  //           border: OutlineInputBorder(),
  //         ),
  //         items: _organizer
  //             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
  //             .toList(),
  //         onChanged: (v) => setState(() => _selectedOrganizer = v),
  //       ),
  //     ],
  //   );
  // }

  // 上传文件表单
  Widget _buildFileUploadForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: const Text('选择文件', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: _isUploading ? null : _pickFile,
        ),
        const SizedBox(height: 12),
        const Text(
          '支持PDF、DOC、JPG、PNG格式，单个文件不超过50MB',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 上传队列文件项
  Widget _buildFileItem(Map<String, dynamic> file) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file["name"]!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                file["date"]!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 18),
            onPressed: _isUploading ? null : () {
              setState(() => _fileQueue.remove(file));
            },
          ),
        ],
      ),
    );
  }
}
