//新建认定奖项弹窗_奖项认定信息管理页面(管理员端)

import 'package:flutter/material.dart';

class CreateAwardDialog extends StatefulWidget {
  const CreateAwardDialog({super.key});

  @override
  _CreateAwardDialogState createState() => _CreateAwardDialogState();
}

class _CreateAwardDialogState extends State<CreateAwardDialog> {
  String selectedSpecialty = '工程';
  String selectedCompetitionName = '材料工程';
  String selectedUnit = '软件工程';
  String selectedCompetitionTime = '2023年';
  String selectedSchool = '物信';
  String selectedGrade = '国家级';
  String fileName = '';  // 用于显示上传的文件名

  // 可选择项
  final List<String> specialties = ['工程', '计算机', '电子'];
  final List<String> competitionNames = ['材料工程', '车铝工程', '软件工程'];
  final List<String> units = ['软件工程', '航天与航空工程', '电子信息工程'];
  final List<String> competitionTimes = ['2023年', '2024年', '2025年'];
  final List<String> schools = ['物信', '计算机学院', '电子学院'];
  final List<String> grades = ['国家级', 'A类竞赛', 'B类竞赛', 'C类竞赛', 'D类竞赛', 'E类竞赛'];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '新建认定奖项',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),

                // 专业选择框
                _buildDropdownField(
                  label: '涉及专业：',
                  value: selectedSpecialty,
                  items: specialties,
                  onChanged: (value) => setState(() {
                    selectedSpecialty = value!;
                  }),
                ),
                const SizedBox(height: 16),

                // 竞赛名称选择框
                _buildDropdownField(
                  label: '竞赛名称：',
                  value: selectedCompetitionName,
                  items: competitionNames,
                  onChanged: (value) => setState(() {
                    selectedCompetitionName = value!;
                  }),
                ),
                const SizedBox(height: 16),

                // 主办单位选择框
                _buildDropdownField(
                  label: '主办单位：',
                  value: selectedUnit,
                  items: units,
                  onChanged: (value) => setState(() {
                    selectedUnit = value!;
                  }),
                ),
                const SizedBox(height: 16),

                // 竞赛时间选择框
                _buildDropdownField(
                  label: '竞赛时间：',
                  value: selectedCompetitionTime,
                  items: competitionTimes,
                  onChanged: (value) => setState(() {
                    selectedCompetitionTime = value!;
                  }),
                ),
                const SizedBox(height: 16),

                // 学校选择框
                _buildDropdownField(
                  label: '学院：',
                  value: selectedSchool,
                  items: schools,
                  onChanged: (value) => setState(() {
                    selectedSchool = value!;
                  }),
                ),
                const SizedBox(height: 16),

                // 认定级别选择框
                _buildDropdownField(
                  label: '认定级别：',
                  value: selectedGrade,
                  items: grades,
                  onChanged: (value) => setState(() {
                    selectedGrade = value!;
                  }),
                ),
                const SizedBox(height: 16),

                // 文件上传
                Row(
                  children: [
                    const Text("通过文件上传："),
                    ElevatedButton.icon(
                      onPressed: () {
                        // 处理文件上传
                        
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('上传文件'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(fileName.isEmpty ? '未选择文件' : fileName),  // 显示文件名
                  ],
                ),
                const SizedBox(height: 16),

                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue),
                      ),
                      child: const Text('重置'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: 保存或提交操作
                        Navigator.pop(context); // 关闭弹窗
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 重置表单的逻辑
  void _resetForm() {
    setState(() {
      selectedSpecialty = '工程';
      selectedCompetitionName = '材料工程';
      selectedUnit = '软件工程';
      selectedCompetitionTime = '2023年';
      selectedSchool = '物信';
      selectedGrade = '国家级';
      fileName = '';  // 清空文件名
    });
  }
  // 处理文件选择的逻辑

  // 下拉框组件
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
