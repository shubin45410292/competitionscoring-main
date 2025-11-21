// 学院信息管理页面(管理员端)

import 'package:competition/util/edit_college_dialog.dart';
import 'package:competition/util/token_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:competition/util/http.dart';

class CollegeInfoPage extends StatefulWidget {
  const CollegeInfoPage({super.key});

  @override
  State<CollegeInfoPage> createState() => _CollegeInfoPageState();
}

class _CollegeInfoPageState extends State<CollegeInfoPage> {
// 分页相关
  int currentPage = 1;
  final int itemsPerPage = 5;
  final TextEditingController _searchController = TextEditingController();

  // 选中值（初始为空，后续从接口加载后赋值）
  String? selectedCollege;
  String? selectedMajor;
  String? selectedCollegeId;

  // 存储接口返回的学院和专业列表
  List<Map<String, String>> collegeList = []; // 格式: [{"CollegeName": "..."}]
  List<Map<String, String>> majorList = [];   // 格式: [{"MajorName": "..."}]
  List<Map<String, String>> allData = [];     // 用于展示的学院专业数据

  // 加载状态
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 页面初始化时加载学院和专业数据
    _loadCollegeData();
  }

  // 1. 先加载学院列表（单独拆分，便于后续复用）
  Future<void> _loadCollegeData() async {
    setState(() => isLoading = true);
    try {
      Response collegeResponse = await get(
        "/admin/colleges",
        queryParameters: {
          "page_size": 10,
          "page_num": currentPage,
        },
      );
      if (collegeResponse.data["base"]["code"] == 10000) {
        List<dynamic> collegeItems = collegeResponse.data["data"]["item"];
        setState(() {
          collegeList = collegeItems.map((item) {
            return {
              "CollegeId": item["CollegeId"].toString(),
              "CollegeName": item["CollegeName"].toString(),
            };
          }).toList();
          // 默认选中第一个学院（同步更新ID）
          if (collegeList.isNotEmpty) {
            selectedCollege = collegeList[0]["CollegeName"];
            selectedCollegeId = collegeList[0]["CollegeId"]; // 初始化选中学院的ID
          }
        });
        // 学院加载完成后，加载对应学院的专业
        if (selectedCollegeId != null) {
          _loadMajorData(selectedCollegeId!);
        }
      } else {
        throw Exception("获取学院列表失败：${collegeResponse.data["base"]["msg"]}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("学院数据加载失败：$e"), backgroundColor: Colors.red),
      );
      setState(() => isLoading = false);
    }
  }
// 2. 加载专业列表（接收college_id参数）
  Future<void> _loadMajorData(String collegeId) async {
    setState(() => isLoading = true);
    try {
      Response majorResponse = await get(
        "/admin/majors",
        queryParameters: {
          "page_size": 10,       // 每页条数
          "page_num": currentPage, // 当前页码
          "college_id": collegeId, // 新增：学院编号（关键参数）
        },
      );
      if (majorResponse.data["base"]["code"] == 10000) {
        List<dynamic> majorItems = majorResponse.data["data"]["item"];
        setState(() {
          majorList = majorItems.map((item) {
            return {
              "MajorId": item["MajorId"].toString(),
              "MajorName": item["MajorName"].toString(),
            };
          }).toList();
          // 默认选中第一个专业
          selectedMajor = majorList.isNotEmpty ? majorList[0]["MajorName"] : null;
        });
        _updateDisplayData(); // 更新表格展示
      } else {
        throw Exception("获取专业列表失败：${majorResponse.data["base"]["msg"]}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("专业数据加载失败：$e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
// 更新展示数据
  void _updateDisplayData() {
    // 若 majorList 为空，直接返回空列表
    if (majorList.isEmpty) {
      setState(() => allData = []);
      return;
    }
    // 否则正常转换
    setState(() {
      allData = majorList.map((major) {
        return {
          "college": selectedCollege ?? "", // 关联选中的学院
          "major": major["MajorName"] ?? "未知专业", // 确保有默认值
        };
      }).toList();
      print("表格展示数据：$allData"); // 检查是否生成了数据
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '学院信息管理',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/adminHome');
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
                    icon: const Icon(Icons.search),
                    onPressed: () {}, // 预留搜索操作
                  ),
                  hintText: '搜索学院或专业',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 下拉筛选行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDropdown(
                  '学院',
                  selectedCollege ?? "",
                  collegeList.map((item) => item["CollegeName"] ?? "").toList(),
                      (value) {
                    if (value != null && collegeList.isNotEmpty) {
                      // 找到选中学院对应的ID
                      final selectedCollegeData = collegeList.firstWhere(
                            (item) => item["CollegeName"] == value,
                        orElse: () => {},
                      );
                      setState(() {
                        selectedCollege = value;
                        selectedCollegeId = selectedCollegeData["CollegeId"];
                      });
                      // 重新加载该学院的专业
                      if (selectedCollegeId != null) {
                        _loadMajorData(selectedCollegeId!);
                      }
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 表头
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        '学院',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '专业',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // 数据表格
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator()) // 加载中
                  : allData.isEmpty
                  ? const Center(child: Text("暂无数据")) // 空数据提示
                  : ListView.separated(
                itemCount: allData.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = allData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(child: Text(item['college'] ?? '未知学院')),
                        ),
                        Expanded(
                          child: Center(child: Text(item['major'] ?? '未知专业')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('新增'),
                ),
                const SizedBox(width: 12),
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
                      builder: (_) => const EditCollegeDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('修改'),
                ),
              ],
            ),

            const SizedBox(height: 12),


            // 分页控制（切换页码时重新加载数据）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: currentPage > 1
                      ? () {
                    setState(() => currentPage--);
                    _loadCollegeData(); // 重新加载学院（会联动加载专业）
                  }
                      : null,
                  child: const Text('上一页'),
                ),
                Text(
                  '$currentPage/5',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: currentPage < 5
                      ? () {
                    setState(() => currentPage++);
                    _loadCollegeData(); // 重新加载学院（会联动加载专业）
                  }
                      : null,
                  child: const Text('下一页'),
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


  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ),
    );
  }
}
