//用户信息管理页面(管理员端)的修改用户信息对话框组件

import 'package:flutter/material.dart';

class EditUserDialog extends StatefulWidget {
  const EditUserDialog({super.key});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  // 控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 学院、专业和年级列表
  final List<String> majorOptions = ['软件工程', '人工智能', '网络安全'];
  final List<String> gradeOptions = ['2023级', '2024级', '2025级'];

  // 默认选中的值
  String selectedMajor = '软件工程';
  String selectedGrade = '2023级';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // 设置圆角
      child: Material(
        color: Colors.transparent, // 确保 Material 是透明的，以便我们能看到背景
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20, // 动态获取底部 padding
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '请选择需要修改的内容',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),

                // 姓名输入框
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // 邮箱输入框
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // 密码输入框
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // 管理专业下拉框
                DropdownButtonFormField<String>(
                  value: selectedMajor,
                  decoration: const InputDecoration(
                    labelText: '管理专业',
                    border: OutlineInputBorder(),
                  ),
                  items: majorOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedMajor = v!),
                ),
                const SizedBox(height: 16),

                // 管理年级下拉框
                DropdownButtonFormField<String>(
                  value: selectedGrade,
                  decoration: const InputDecoration(
                    labelText: '管理年级',
                    border: OutlineInputBorder(),
                  ),
                  items: gradeOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedGrade = v!),
                ),
                const SizedBox(height: 20),

                // 底部按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _nameController.clear();
                        _emailController.clear();
                        _passwordController.clear();
                      },
                      child: const Text('重置'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: 这里写保存逻辑
                        Navigator.pop(context);  // 关闭弹窗
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
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
}
