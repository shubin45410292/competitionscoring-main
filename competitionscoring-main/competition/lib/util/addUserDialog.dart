//用户信息管理页面(管理员端)的添加用户弹窗组件

import 'package:flutter/material.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  int selectedTab = 0; // 0 = 管理员, 1 = 辅导员, 2 = 学生

  // 控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 学院和专业列表
  final List<String> collegeOptions = ['计算机与大数据', '外国语', '管理学院'];
  final List<String> majorOptions = ['软件工程', '人工智能', '网络安全'];
  final List<String> gradeOptions = ['2023级', '2024级', '2025级']; // 年级列表

  // 角色数据
  String selectedCollege = '计算机与大数据';
  String selectedMajor = '软件工程';
  String selectedGrade = '2023级'; // 默认年级
  String selectedRole = '辅导员';  // 默认角色是辅导员

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
                  '请选择需要添加的内容（管理员/辅导员/学生）',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),

                // 顶部切换按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabButton('管理员', 0),
                    _buildTabButton('辅导员', 1),
                    _buildTabButton('学生', 2),
                  ],
                ),
                const SizedBox(height: 20),

                // 根据选中的角色展示不同的表单内容
                if (selectedTab == 0)
                  _buildAdminForm(),
                if (selectedTab == 1)
                  _buildCounselorForm(),
                if (selectedTab == 2)
                  _buildStudentForm(),

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

  // Tab切换按钮
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

  // ---------------- 管理员表单 ----------------
  Widget _buildAdminForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '姓名',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: '邮箱',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }

  // ---------------- 辅导员表单 ----------------
  Widget _buildCounselorForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '姓名',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: '邮箱',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }

  // ---------------- 学生表单 ----------------
  Widget _buildStudentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '姓名',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedCollege,
          decoration: const InputDecoration(
            labelText: '学院',
            border: OutlineInputBorder(),
          ),
          items: collegeOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedCollege = v!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedMajor,
          decoration: const InputDecoration(
            labelText: '专业',
            border: OutlineInputBorder(),
          ),
          items: majorOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedMajor = v!),
        ),
        const SizedBox(height: 16),
        // 年级下拉框
        DropdownButtonFormField<String>(
          value: selectedGrade,
          decoration: const InputDecoration(
            labelText: '年级',
            border: OutlineInputBorder(),
          ),
          items: gradeOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedGrade = v!),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: '邮箱',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: '密码',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
