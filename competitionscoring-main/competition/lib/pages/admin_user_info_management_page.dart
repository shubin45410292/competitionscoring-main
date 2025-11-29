import 'package:competition/util/addUserDialog.dart';
import 'package:flutter/material.dart';
import '../util/edit_college_dialog.dart';
import 'package:competition/util/http.dart'; // 导入封装的HTTP工具

class AdminUserInfoManagementPage extends StatefulWidget {
  const AdminUserInfoManagementPage({super.key});

  @override
  State<AdminUserInfoManagementPage> createState() => _AdminUserInfoManagementPageState();
}

class _AdminUserInfoManagementPageState extends State<AdminUserInfoManagementPage> {
  int currentPage = 1;
  final int itemsPerPage = 5;
  final TextEditingController _searchController = TextEditingController();

  // 数据状态管理
  List<Map<String, dynamic>> allData = []; // 存储接口返回的用户数据
  bool isLoading = true;
  String errorMsg = "";
  int totalCount = 0; // 总数据量（用于分页）

  // 筛选条件（移除专业筛选）
  String selectedCollege = '全部学院';
  String selectedRole = '全部角色';

  // 下拉选项（移除专业相关选项）
  final List<String> collegeOptions = [
    '全部学院',
    '外国语学院',
    '计算机与大数据学院',
    '环境科学与工程学院',
    '理学院',
    '电子与信息工程学院',
    '经济管理学院',
    '人文社会科学学院',
    '医学院',
    '艺术学院'
  ];
  final List<String> roleOptions = ['全部角色', '学生', '管理员', '辅导员'];

  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    _fetchUserData();
  }

  // 从后端获取用户数据（移除专业筛选参数）
  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
      errorMsg = "";
    });

    try {
      // 构建请求参数（去掉专业筛选参数）
      final queryParameters = {
        if (selectedCollege != '全部学院') 'college': selectedCollege,
        if (selectedRole != '全部角色') 'role': _convertRoleToApi(selectedRole),
        'page_num': currentPage.toString(),
        'page_size': itemsPerPage.toString(),
        // 搜索参数（如果有搜索内容）
        if (_searchController.text.isNotEmpty) 'username': _searchController.text.trim(),
      };

      // 调用封装的GET方法请求接口
      final response = await get(
        '/admin/user/info', // 接口路径（已拼接baseUrl）
        queryParameters: queryParameters,
      );

      // 解析响应数据
      Map<String, dynamic> responseData = response.data;
      if (responseData['base']?['code'] == 10000) {
        // 接口调用成功
        setState(() {
          allData = List<Map<String, dynamic>>.from(responseData['data']?['item'] ?? []);
          totalCount = responseData['data']?['total'] ?? 0;
          isLoading = false;
        });
      } else {
        // 接口返回错误信息
        throw Exception(responseData['base']?['msg'] ?? '获取用户数据失败');
      }
    } catch (e) {
      // 请求失败处理
      setState(() {
        errorMsg = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
      print('获取用户数据失败：$e');
    }
  }

  // 将前端角色文本转换为接口所需的参数（如：学生 -> student）
  String _convertRoleToApi(String role) {
    switch (role) {
      case '学生':
        return 'student';
      case '管理员':
        return 'admin';
      case '辅导员':
        return 'counselor';
      default:
        return role;
    }
  }

  // 将接口返回的角色参数转换为前端显示文本（如：student -> 学生）
  String _convertRoleToDisplay(String role) {
    switch (role) {
      case 'student':
        return '学生';
      case 'admin':
        return '管理员';
      case 'counselor':
        return '辅导员';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4A90E2);
    const Color bgColor = Color(0xFFF7F8FA);
    const double cardRadius = 12;

    // 计算总页数（基于接口返回的total）
    final totalPages = (totalCount / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '用户信息管理',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/adminHome',
                  (route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 搜索栏
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        currentPage = 1; // 搜索后重置到第一页
                        _fetchUserData(); // 重新请求数据
                      });
                    },
                  ),
                  hintText: '搜索姓名',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onSubmitted: (_) {
                  setState(() {
                    currentPage = 1;
                    _fetchUserData();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // 筛选行（移除专业下拉框，调整布局为2列均分）
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown('学院', selectedCollege, collegeOptions, (v) {
                  setState(() {
                    selectedCollege = v!;
                    currentPage = 1;
                    _fetchUserData(); // 筛选条件变化后重新请求
                  });
                }),
                const SizedBox(width: 8),
                _buildDropdown('角色', selectedRole, roleOptions, (v) {
                  setState(() {
                    selectedRole = v!;
                    currentPage = 1;
                    _fetchUserData();
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),

            // 表格头（保持不变，仍显示专业列，仅移除筛选功能）
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Row(
                children: [
                  Expanded(flex: 1, child: Center(child: Text('姓名', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
                  Expanded(flex: 2, child: Center(child: Text('角色', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
                  Expanded(flex: 2, child: Center(child: Text('学院', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
                  Expanded(flex: 2, child: Center(child: Text('专业', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
                  Expanded(flex: 2, child: Center(child: Text('年级', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // 表格数据（处理加载、错误、无数据状态）
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                  : errorMsg.isNotEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMsg, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchUserData,
                      child: const Text('重新加载'),
                    ),
                  ],
                ),
              )
                  : allData.isEmpty
                  ? const Center(child: Text('暂无匹配数据'))
                  : ListView.separated(
                itemCount: allData.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  final item = allData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Center(child: Text(item['username'] ?? '未知', style: const TextStyle(fontSize: 14)))),
                        Expanded(flex: 2, child: Center(child: Text(_convertRoleToDisplay(item['role'] ?? '未知'), style: const TextStyle(fontSize: 14)))),
                        Expanded(flex: 2, child: Center(child: Text(item['college'] ?? '未知', style: const TextStyle(fontSize: 14)))),
                        Expanded(flex: 2, child: Center(child: Text(item['Major'] ?? '未知', style: const TextStyle(fontSize: 14)))),
                        Expanded(flex: 2, child: Center(child: Text(item['grade'] ?? '未知', style: const TextStyle(fontSize: 14)))),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 1, height: 1),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                      builder: (_) => const AddUserDialog(),
                    ).then((_) {
                      // 关闭弹窗后刷新数据
                      _fetchUserData();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('新增'),
                ),
                const SizedBox(width: 12),
              ],
            ),

            const SizedBox(height: 12),

            // 分页控制
            if (!isLoading && errorMsg.isEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: currentPage > 1
                        ? () => setState(() {
                      currentPage--;
                      _fetchUserData();
                    })
                        : null,
                    child: const Text('上一页'),
                    style: TextButton.styleFrom(
                      foregroundColor: currentPage > 1 ? primaryBlue : Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$currentPage/$totalPages',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: currentPage < totalPages && totalPages > 0
                        ? () => setState(() {
                      currentPage++;
                      _fetchUserData();
                    })
                        : null,
                    child: const Text('下一页'),
                    style: TextButton.styleFrom(
                      foregroundColor: (currentPage < totalPages && totalPages > 0) ? primaryBlue : Colors.grey,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // 底部状态栏
            const Text(
              '2025年10月9日 14:30   系统版本v2.3.1   服务状态：正常',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // 下拉框组件（保持不变）
  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            items: options
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
              ),
            ))
                .toList(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
