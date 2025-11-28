//辅导员端：  查看学生积分排行页面
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'student_score_detail_page.dart';
import 'package:competition/util/token_util.dart';
import 'package:competition/util/http.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  int currentPage = 1;
  final int itemsPerPage = 5;
  final TextEditingController _searchController = TextEditingController();

  // 数据相关
  List<Map<String, dynamic>> allData = [];
  bool isLoading = true;
  String? errorMsg;
  int totalCount = 0; // 总数据量
  // 筛选条件
  String selectedYear = '全部';
  String selectedCollege = '全部';
  final List<String> yearOptions = ['全部','2022','2023','2024','2025'];
  final List<String> collegeOptions = ['全部', '计算机与大数据学院', '电子与信息工程学院', '机械工程学院','土木建筑工程学院',
  '经济管理学院','外国语学院','理学院','人文社会科学学院','医学院','艺术学院','法学院','环境科学与工程学院'];

  @override
  void initState() {
    super.initState();
    // 初始化时加载数据（直接使用封装的 get 方法）
    _fetchRankData();
  }

  // 从后端获取排名数据（使用封装的 HTTP get 方法）
  Future<void> _fetchRankData() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      // 构建查询参数（空值不传递）
      Map<String, dynamic> queryParams = {};

      // 搜索框内容（学生姓名）
      if (_searchController.text.trim().isNotEmpty) {
        queryParams['stu_name'] = _searchController.text.trim();
      }

      // 年级
      if (selectedYear != '全部') {
        queryParams['grade'] = selectedYear;
      }

      // 学院（"全部"则不传递）
      if (selectedCollege != '全部') {
        queryParams['college'] = selectedCollege;
      }

      // 直接使用封装的 get 方法（无需重复定义 HTTP 逻辑）
      Response response = await get(
        '/score/query/rank',
        queryParameters: queryParams,
      );

      // 解析响应
      if (response.data['base']['code'] == 10000) {
        List<dynamic> items = response.data['data']['item'] ?? [];
        setState(() {
          // 处理排名数据（添加rank字段）
          allData = items.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
            return {
              'rank': index + 1, // 排名从1开始
              'stu_id': item['stu_id'] ?? '',
              'stu_name': item['stu_name'] ?? '未知',
              'college': item['college'] ?? '未知学院',
              'grade': item['grade'] ?? '未知年级',
              'score': item['Score']?.toString() ?? '0',
            };
          }).toList();
          totalCount = response.data['data']['total'] ?? 0;
        });
      } else {
        throw Exception(response.data['base']['msg'] ?? '获取排名失败');
      }
    } catch (e) {
      setState(() {
        // 直接使用封装的错误信息格式（无需重复定义 _formatError）
        errorMsg = e.toString().replaceAll('Exception: ', '');
      });
      print('获取排名数据异常：$e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 计算当前页数据
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, allData.length);
    final currentData = allData.sublist(start, end);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          '积分排名',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 15),
            // 搜索栏
            Container(
              width: 340,
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
                    onPressed: _handleSearch, // 点击图标搜索
                  ),
                  hintText: '搜索学生姓名',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _handleSearch(), // 回车搜索
              ),
            ),

            const SizedBox(height: 25),

            // 筛选行
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDropdown('学年', selectedYear, yearOptions, (v) {
                    if (v != null) {
                      setState(() {
                        selectedYear = v;
                        currentPage = 1; // 重置页码
                      });
                      _fetchRankData(); // 重新加载数据
                    }
                  }),
                  const SizedBox(width: 16),
                  _buildDropdown('学院', selectedCollege, collegeOptions, (v) {
                    if (v != null) {
                      setState(() {
                        selectedCollege = v;
                        currentPage = 1; // 重置页码
                      });
                      _fetchRankData(); // 重新加载数据
                    }
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 表格头
            Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                children: [
                  Expanded(flex: 1, child: Center(child: Text('排名', style: TextStyle(fontWeight: FontWeight.bold)))),
                  Expanded(flex: 2, child: Center(child: Text('姓名', style: TextStyle(fontWeight: FontWeight.bold)))),
                  Expanded(flex: 3, child: Center(child: Text('学院', style: TextStyle(fontWeight: FontWeight.bold)))),
                  Expanded(flex: 2, child: Center(child: Text('年级', style: TextStyle(fontWeight: FontWeight.bold)))),
                  Expanded(flex: 2, child: Center(child: Text('积分', style: TextStyle(fontWeight: FontWeight.bold)))),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // 表格数据/加载状态/错误提示
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMsg != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextButton(
                      onPressed: _fetchRankData,
                      child: const Text('重试'),
                    ),
                  ],
                ),
              )
                  : allData.isEmpty
                  ? const Center(child: Text('暂无数据'))
                  : ListView.separated(
                itemCount: currentData.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = currentData[index];
                  return InkWell(
                    //TODO:点击跳转到详情页
                    // 点击跳转到详情页
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentScoreDetailPage(
                          studentName: item['stu_name'],
                          //studentId: item['stu_id'], // 传递学生ID
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Center(child: Text(item['rank'].toString()))),
                          Expanded(flex: 2, child: Center(child: Text(item['stu_name']))),
                          Expanded(flex: 3, child: Center(child: Text(item['college']))),
                          Expanded(flex: 2, child: Center(child: Text(item['grade']))),
                          Expanded(flex: 2, child: Center(child: Text(item['score']))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(thickness: 1, height: 1),

            // 分页控制
            if (!isLoading && errorMsg == null && allData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: currentPage > 1
                          ? () => setState(() => currentPage--)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('上一页', style: TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '$currentPage / ${((totalCount - 1) ~/ itemsPerPage) + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: end < totalCount
                          ? () => setState(() => currentPage++)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('下一页', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 搜索逻辑
  void _handleSearch() {
    setState(() {
      currentPage = 1; // 重置页码
    });
    _fetchRankData(); // 重新加载数据
  }

  // 下拉框组件
  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
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
