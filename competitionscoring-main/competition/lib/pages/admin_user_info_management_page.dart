//用户信息管理页面(管理员端)

import 'package:competition/util/addUserDialog.dart';
import 'package:flutter/material.dart';

import '../util/edit_college_dialog.dart';

class AdminUserInfoManagementPage extends StatefulWidget {
  const AdminUserInfoManagementPage({super.key});

  @override
  State<AdminUserInfoManagementPage> createState() => _AdminUserInfoManagementPageState();
}

class _AdminUserInfoManagementPageState extends State<AdminUserInfoManagementPage> {
  int currentPage = 1;
  final int itemsPerPage = 5;
  final TextEditingController _searchController = TextEditingController();

  // 扩充用户数据，增加更多姓名、学院、专业组合
  final List<Map<String, String>> allData = List.generate(30, (index) {
    // 更多姓名选项
    final names = ['张三', '李四', '王五', '赵六', '孙七', '周八', '吴九', '郑十', '钱十一', '冯十二', '陈十三', '褚十四', '卫十五', '蒋十六', '沈十七'];
    // 更多学院选项
    final colleges = ['计算机与大数据', '设计学院', '管理学院', '电子信息学院', '自动化学院', '外国语学院', '文学院', '理学院'];
    // 更多专业选项
    final majors = [
      '软件工程', '计算机科学与技术', '数据科学与大数据技术',
      '视觉传达设计', '环境设计', '产品设计',
      '工商管理', '市场营销', '人力资源管理',
      '电子信息工程', '通信工程', '物联网工程',
      '自动化', '智能科学与技术',
      '英语', '日语',
      '汉语言文学', '新闻学',
      '数学与应用数学', '物理学'
    ];
    // 年级选项
    final enrollmentYears = ['2021年', '2022年', '2023年', '2024年'];

    return {
      'name': names[index % names.length],
      'role': ['学生', '管理员', '辅导员'][index % 3], // 增加辅导员角色
      'college': colleges[index % colleges.length],
      'major': majors[index % majors.length],
      'enrollmentYear': enrollmentYears[index % enrollmentYears.length],
    };
  });

  // 筛选条件（去掉选项中的前缀文字，更简洁）
  String selectedCollege = '全部学院';
  String selectedRole = '全部角色';
  String selectedMajor = '全部专业';

  // 下拉选项（优化格式，去掉前缀）
  final List<String> collegeOptions = [
    '全部学院',
    '计算机与大数据',
    '设计学院',
    '管理学院',
    '电子信息学院',
    '自动化学院',
    '外国语学院',
    '文学院',
    '理学院'
  ];
  final List<String> roleOptions = ['全部角色', '学生', '管理员', '辅导员'];
  final List<String> majorOptions = [
    '全部专业',
    '软件工程', '计算机科学与技术', '数据科学与大数据技术',
    '视觉传达设计', '环境设计', '产品设计',
    '工商管理', '市场营销', '人力资源管理',
    '电子信息工程', '通信工程', '物联网工程',
    '自动化', '智能科学与技术',
    '英语', '日语',
    '汉语言文学', '新闻学',
    '数学与应用数学', '物理学'
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4A90E2);
    const Color bgColor = Color(0xFFF7F8FA);
    const double cardRadius = 12;

    // 筛选逻辑：根据选中的条件过滤数据
    final filteredData = allData.where((item) {
      // 学院筛选
      final collegeMatch = selectedCollege == '全部学院' || item['college'] == selectedCollege;
      // 专业筛选
      final majorMatch = selectedMajor == '全部专业' || item['major'] == selectedMajor;
      // 角色筛选
      final roleMatch = selectedRole == '全部角色' || item['role'] == selectedRole;
      // 搜索筛选（姓名包含搜索文字）
      final searchMatch = _searchController.text.trim().isEmpty ||
          item['name']!.contains(_searchController.text.trim());

      return collegeMatch && majorMatch && roleMatch && searchMatch;
    }).toList();

    // 分页逻辑（基于筛选后的数据）
    final totalPages = (filteredData.length / itemsPerPage).ceil();
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, filteredData.length);
    final currentData = filteredData.sublist(start, end);

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
              width: double.infinity, // 适配屏幕宽度
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
                      });
                    },
                  ),
                  hintText: '搜索姓名',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onSubmitted: (_) {
                  setState(() {
                    currentPage = 1; // 搜索后重置到第一页
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // 筛选行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown('学院', selectedCollege, collegeOptions, (v) {
                  setState(() {
                    selectedCollege = v!;
                    currentPage = 1; // 筛选后重置到第一页
                  });
                }),
                const SizedBox(width: 8),
                _buildDropdown('专业', selectedMajor, majorOptions, (v) {
                  setState(() {
                    selectedMajor = v!;
                    currentPage = 1; // 筛选后重置到第一页
                  });
                }),
                const SizedBox(width: 8),
                _buildDropdown('角色', selectedRole, roleOptions, (v) {
                  setState(() {
                    selectedRole = v!;
                    currentPage = 1; // 筛选后重置到第一页
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),

            // 表格头
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

            // 表格数据（处理无数据情况）
            Expanded(
              child: currentData.isEmpty
                  ? const Center(child: Text('暂无匹配数据'))
                  : ListView.separated(
                itemCount: currentData.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  final item = currentData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(flex: 1, child: Center(child: Text(item['name']!, style: const TextStyle(fontSize: 14)))),
                        Expanded(flex: 2, child: Center(child: Text(item['role']!, style: const TextStyle(fontSize: 14)))),
                        Expanded(flex: 2, child: Center(child: Text(item['college']!, style: const TextStyle(fontSize: 14)))),
                        Expanded(flex: 2, child: Center(child: Text(item['major']!, style: const TextStyle(fontSize: 14)))),
                        Expanded(flex: 2, child: Center(child: Text(item['enrollmentYear']!, style: const TextStyle(fontSize: 14)))),
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
                      builder: (_) => const AddUserDialog(),// 添加用户弹窗组件
                    );
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
            //     ElevatedButton(
            //       onPressed: () {
            //         showModalBottomSheet(
            //           context: context,
            //           isScrollControlled: true,
            //           backgroundColor: Colors.white,
            //           shape: const RoundedRectangleBorder(
            //             borderRadius: BorderRadius.vertical(
            //               top: Radius.circular(18),
            //             ),
            //           ),
            //           builder: (_) => const EditCollegeDialog(),// 修改用户信息组件
            //         );
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.orange[500],
            //         foregroundColor: Colors.white,
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 20,
            //           vertical: 10,
            //         ),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //       ),
            //       child: const Text('修改'),
            //     ),
            //     const SizedBox(width: 12),
            //     ElevatedButton(
            //       onPressed: () {
            //         // 删除确认弹窗
            //         showDialog(
            //           context: context,
            //           builder: (context) => AlertDialog(
            //             title: const Text('确认删除'),
            //             content: const Text('确定要删除选中的用户吗？此操作不可撤销。'),
            //             actions: [
            //               TextButton(
            //                 onPressed: () => Navigator.pop(context),
            //                 child: const Text('取消'),
            //               ),
            //               TextButton(
            //                 onPressed: () {
            //                   // 这里可以添加实际的删除逻辑
            //                   Navigator.pop(context);
            //                   ScaffoldMessenger.of(context).showSnackBar(
            //                     const SnackBar(content: Text('删除成功')),
            //                   );
            //                 },
            //                 child: const Text('删除', style: TextStyle(color: Colors.red)),
            //               ),
            //             ],
            //           ),
            //         );
            //       },
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.red[500],
            //         foregroundColor: Colors.white,
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 20,
            //           vertical: 10,
            //         ),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //       ),
            //       child: const Text('删除'),
            //     ),
              ],
            ),

            const SizedBox(height: 12),

            // 分页控制（基于筛选后的数据）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: currentPage > 1
                      ? () => setState(() => currentPage--)
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
                      ? () => setState(() => currentPage++)
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

  // 下拉框组件
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
                overflow: TextOverflow.ellipsis, // 处理文字过长
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
