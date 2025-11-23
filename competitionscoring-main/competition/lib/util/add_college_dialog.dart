import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/http.dart'; // 导入你的HTTP工具封装

// 学院数据模型（CollegeId转为String类型）
class CollegeModel {
  final String collegeId; // 统一转为String类型
  final String collegeName;

  CollegeModel({
    required this.collegeId,
    required this.collegeName,
  });

  // 从JSON解析模型（将int类型的CollegeId转为String）
  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    // 处理后端返回的int类型CollegeId，转为String
    String id = '';
    if (json['CollegeId'] is int) {
      id = json['CollegeId'].toString(); // int转String
    } else if (json['CollegeId'] is String) {
      id = json['CollegeId']; // 若后端返回String，直接使用
    }

    return CollegeModel(
      collegeId: id,
      collegeName: json['CollegeName'] ?? '未知学院',
    );
  }
}

class AddCollegeDialog extends StatefulWidget {
  const AddCollegeDialog({super.key});

  @override
  State<AddCollegeDialog> createState() => _AddCollegeDialogState();
}

class _AddCollegeDialogState extends State<AddCollegeDialog> {
  int selectedTab = 0; // 0 = 学院，1 = 专业

  // ---- 学院模式数据 ----
  final TextEditingController _collegeNameController = TextEditingController();

  // ---- 专业模式数据 ----
  final TextEditingController _majorNameController = TextEditingController();
  List<CollegeModel> _collegeList = []; // 动态加载的学院列表
  String? _selectedCollegeId; // 选中的学院ID（String类型）
  bool _isLoadingColleges = false; // 学院列表加载状态
  String? _errorMsg; // 错误信息

  @override
  void initState() {
    super.initState();
    // 初始化时加载学院列表（专业模式需要）
    _fetchCollegeList();
  }

  // 从后端获取学院列表（page_size=10，page_num=1）
  Future<void> _fetchCollegeList() async {
    setState(() {
      _isLoadingColleges = true;
      _errorMsg = null;
    });

    try {
      // 构造查询参数（强制page_size=10，page_num=1）
      Map<String, dynamic> queryParams = {
        'page_size': 10,
        'page_num': 1,
      };

      // 发送GET请求
      Response response = await get(
        '/admin/colleges', // 接口路径（拼接baseUrl）
        queryParameters: queryParams,
      );

      // 解析响应
      if (response.data['base']['code'] == 10000) {
        List<dynamic> items = response.data['data']['item'] ?? [];
        setState(() {
          _collegeList = items.map((item) => CollegeModel.fromJson(item)).toList();
          // 默认选中第一个学院（如果有数据）
          if (_collegeList.isNotEmpty) {
            _selectedCollegeId = _collegeList.first.collegeId;
          }
        });
      } else {
        throw Exception("获取学院列表失败：${response.data['base']['msg'] ?? '未知错误'}");
      }
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
      print("获取学院列表异常：$e");
    } finally {
      setState(() {
        _isLoadingColleges = false;
      });
    }
  }

  // 提交新增学院
  Future<void> _submitCollege() async {
    String collegeName = _collegeNameController.text.trim();
    if (collegeName.isEmpty) {
      _showToast('请输入学院名称');
      return;
    }

    try {
      // 构造请求参数
      Map<String, dynamic> params = {
        'college_name': collegeName,
      };

      // 发送POST请求
      Response response = await post(
        '/admin/colleges', // 新增学院接口
        data: params,
      );

      // 解析响应
      if (response.data['base']['code'] == 10000) {
        String collegeId = response.data['college_id'].toString(); // int转String
        _showToast('新增学院成功！学院ID：$collegeId');
        Navigator.pop(context, true); // 关闭对话框并返回成功状态
      } else {
        _showToast('新增失败：${response.data['base']['msg'] ?? '未知错误'}');
      }
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      _showToast('新增失败：$errorMsg');
      print("新增学院异常：$e");
    }
  }

  // 提交新增专业
  Future<void> _submitMajor() async {
    String majorName = _majorNameController.text.trim();
    if (majorName.isEmpty) {
      _showToast('请输入专业名称');
      return;
    }

    if (_selectedCollegeId == null || _selectedCollegeId!.isEmpty) {
      _showToast('请选择所属学院');
      return;
    }

    try {
      // 构造请求参数（college_id为String类型，后端会自动解析）
      Map<String, dynamic> params = {
        'major_name': majorName,
        'college_id': _selectedCollegeId, // String类型的学院ID
      };

      // 发送POST请求
      Response response = await post(
        '/admin/majors', // 新增专业接口
        data: params,
      );

      // 解析响应
      if (response.data['base']['code'] == 10000) {
        String majorId = response.data['major_id'].toString(); // int转String
        _showToast('新增专业成功！专业ID：$majorId');
        Navigator.pop(context, true); // 关闭对话框并返回成功状态
      } else {
        _showToast('新增失败：${response.data['base']['msg'] ?? '未知错误'}');
      }
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      _showToast('新增失败：$errorMsg');
      print("新增专业异常：$e");
    }
  }

  // 显示提示信息
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              '请选择需要新增的内容（学院/专业）',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),

            // 顶部切换按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton('学院', 0),
                _buildTabButton('专业', 1),
              ],
            ),

            const SizedBox(height: 20),

            // 错误提示（如果有）
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

            // 切换显示不同表单
            if (selectedTab == 0)
              _buildCollegeEditForm()
            else
              _buildMajorEditForm(),

            const SizedBox(height: 20),

            // 底部按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // 重置表单
                    _collegeNameController.clear();
                    _majorNameController.clear();
                    if (_collegeList.isNotEmpty) {
                      setState(() => _selectedCollegeId = _collegeList.first.collegeId);
                    }
                  },
                  child: const Text('重置'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 根据当前Tab执行对应提交逻辑
                    if (selectedTab == 0) {
                      _submitCollege();
                    } else {
                      _submitMajor();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  ),
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
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

  // ---------------- 学院修改表单 ----------------
  Widget _buildCollegeEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _collegeNameController,
          decoration: const InputDecoration(
            labelText: '学院名称',
            hintText: '请输入要新增的学院名称',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitCollege(), // 回车提交
        ),
      ],
    );
  }

  // ---------------- 专业修改表单 ----------------
  Widget _buildMajorEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 专业名称输入框
        TextField(
          controller: _majorNameController,
          decoration: const InputDecoration(
            labelText: '专业名称',
            hintText: '请输入要新增的专业名称',
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        // 所属学院下拉框（动态加载）
        _isLoadingColleges
            ? // 加载中状态
        const InputDecorator(
          decoration: InputDecoration(
            labelText: '所属学院',
            border: OutlineInputBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue),
              SizedBox(width: 8),
              Text('加载学院中...'),
            ],
          ),
        )
            : _collegeList.isEmpty
            ? // 无数据状态
        InputDecorator(
          decoration: InputDecoration(
            labelText: '所属学院',
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '暂无学院数据',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              TextButton(
                onPressed: _fetchCollegeList,
                child: const Text('重试'),
              ),
            ],
          ),
        )
            : // 正常下拉框（value为String类型）
        DropdownButtonFormField<String>(
          value: _selectedCollegeId,
          decoration: const InputDecoration(
            labelText: '所属学院',
            border: OutlineInputBorder(),
          ),
          // 构建下拉选项（value为String类型的collegeId）
          items: _collegeList
              .map((college) => DropdownMenuItem(
            value: college.collegeId, // String类型
            child: Text(college.collegeName),
          ))
              .toList(),
          onChanged: (value) => setState(() {
            _selectedCollegeId = value;
          }),
          validator: (value) =>
          value == null ? '请选择所属学院' : null,
        ),
      ],
    );
  }
}
