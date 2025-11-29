import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/http.dart'; // 导入封装的HTTP工具

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  int selectedTab = 1; // 1=辅导员管理范围, 2=学生

  // 控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController(); // 新增：工号控制器

  // 学院和专业列表
  final List<String> collegeOptions = ['计算机与大数据学院', '外国语学院', '管理学院'];
  final List<String> majorOptions = ['软件工程', '人工智能', '网络安全'];
  final List<String> gradeOptions = ['23', '24', '25']; // 修改：年级格式改为两位数（匹配接口要求）

  // 角色数据
  String selectedCollege = '计算机与大数据学院';
  String selectedMajor = '软件工程';
  String selectedGrade = '23'; // 默认年级
  String selectedRole = 'counselor';  // 接口需要的角色值

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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '请选择需要添加的内容（辅导员管理范围/学生）',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),

                // 顶部切换按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabButton('辅导员管理范围', 1),
                    _buildTabButton('学生', 2),
                  ],
                ),
                const SizedBox(height: 20),

                // 表单内容
                if (selectedTab == 1)
                  _buildCounselorPermissionForm(),
                if (selectedTab == 2)
                  _buildStudentForm(),

                const SizedBox(height: 20),

                // 底部按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _resetForm();
                      },
                      child: const Text('重置'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedTab == 1) {
                          _submitCounselorPermission();
                        } else {
                          _submitStudent();
                        }
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

  // 重置表单
  void _resetForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _userIdController.clear();
    setState(() {
      selectedCollege = '计算机与大数据学院';
      selectedMajor = '软件工程';
      selectedGrade = '23';
    });
  }

  // 提交辅导员管理范围
  Future<void> _submitCounselorPermission() async {
    // 表单验证
    if (_userIdController.text.trim().isEmpty) {
      _showSnackBar('请输入工号');
      return;
    }

    try {
      // 构建form-data参数
      final formData = FormData.fromMap({
        'user_id': _userIdController.text.trim(),
        'major_name': selectedMajor,
        'grade': selectedGrade,
        'college_name': selectedCollege,
      });

      // 调用添加权限接口
      final response = await postFormData(
        '/admin/users/permission',
        formData: formData,
      );

      // 解析响应
      Map<String, dynamic> responseData = response.data;
      if (responseData['base']?['code'] == 10000) {
        _showSnackBar('添加辅导员管理范围成功');
        Navigator.pop(context); // 关闭弹窗
      } else {
        _showSnackBar('添加失败: ${responseData['base']?['msg'] ?? '未知错误'}');
      }
    } catch (e) {
      _showSnackBar('请求失败: ${e.toString().replaceAll('Exception: ', '')}');
      print('添加辅导员管理范围错误: $e');
    }
  }

  // 提交学生信息
  Future<void> _submitStudent() async {
    // 表单验证
    if (_userIdController.text.trim().isEmpty) {
      _showSnackBar('请输入工号');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('请输入姓名');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showSnackBar('请输入密码');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('请输入邮箱');
      return;
    }

    try {
      // 构建form-data参数
      final formData = FormData.fromMap({
        'user_role': 'student', // 学生角色固定值
        'user_id': _userIdController.text.trim(),
        'password': _passwordController.text.trim(),
        'email': _emailController.text.trim(),
        'username': _nameController.text.trim(),
        'college': selectedCollege,
        'major_name': selectedMajor,
        'grade': selectedGrade,
      });

      // 调用添加学生接口
      final response = await postFormData(
        '/admin/users',
        formData: formData,
      );

      // 解析响应
      Map<String, dynamic> responseData = response.data;
      if (responseData['base']?['code'] == 10000) {
        _showSnackBar('添加学生成功，学号: ${responseData['user_id'] ?? ''}');
        Navigator.pop(context); // 关闭弹窗
      } else {
        _showSnackBar('添加失败: ${responseData['base']?['msg'] ?? '未知错误'}');
      }
    } catch (e) {
      _showSnackBar('请求失败: ${e.toString().replaceAll('Exception: ', '')}');
      print('添加学生错误: $e');
    }
  }

  // 显示提示信息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Tab切换按钮
  Widget _buildTabButton(String label, int index) {
    final bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        width: 140,
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
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // 辅导员管理范围表单
  Widget _buildCounselorPermissionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _userIdController,
          decoration: const InputDecoration(
            labelText: '工号',
            border: OutlineInputBorder(),
            hintText: '请输入辅导员工号',
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
            hintText: '如：23表示2023级',
          ),
          items: gradeOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedGrade = v!),
        ),
      ],
    );
  }

  // 学生表单
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
        TextField(
          controller: _userIdController,
          decoration: const InputDecoration(
            labelText: '学号',
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
        DropdownButtonFormField<String>(
          value: selectedGrade,
          decoration: const InputDecoration(
            labelText: '年级',
            border: OutlineInputBorder(),
            hintText: '如：23表示2023级',
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
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: '密码',
            border: OutlineInputBorder(),
          ),
          obscureText: true, // 密码隐藏
        ),
      ],
    );
  }
}
