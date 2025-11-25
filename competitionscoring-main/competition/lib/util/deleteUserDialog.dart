//用户信息管理页面(管理员端)的删除用户对话框组件

import 'package:flutter/material.dart';

class DeleteUserDialog extends StatefulWidget {
  const DeleteUserDialog({super.key});

  @override
  _DeleteUserDialogState createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  // 控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // 示例数据：假设是要删除的用户信息
  String name = "张三";
  String email = "zhangsan@example.com";

  @override
  Widget build(BuildContext context) {
    // 预先填充用户数据，用户无法编辑
    _nameController.text = name;
    _emailController.text = email;

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
                  '确认删除用户信息？',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),

                // 姓名输入框，设置为只读
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false, // 禁止编辑
                ),
                const SizedBox(height: 16),

                // 邮箱输入框，设置为只读
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false, // 禁止编辑
                ),
                const SizedBox(height: 20),

                // 底部按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // 点击后关闭弹窗，不做任何操作
                        Navigator.pop(context);
                      },
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: 删除操作的逻辑
                        // 这里可以加入删除操作，如从数据库或列表中删除该用户
                        Navigator.pop(context);  // 关闭弹窗
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600], // 红色表示删除操作
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                      ),
                      child: const Text(
                        '删除',
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
