// 学生积分详情页面(教师端)
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/http.dart'; // 导入封装的http工具

class StudentScoreDetailPage extends StatefulWidget {
  final String studentName;
  final String studentId; // 接收学号参数（必填）

  const StudentScoreDetailPage({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<StudentScoreDetailPage> createState() => _StudentScoreDetailPageState();
}

class _StudentScoreDetailPageState extends State<StudentScoreDetailPage> {
  // 数据状态管理
  List<Map<String, dynamic>> materialList = [];
  Map<String, double> eventScores = {};
  double totalScore = 0;
  bool isLoading = true;
  String errorMsg = "";

  // 分页参数
  int currentPage = 1;
  final int pageSize = 10;
  int totalItems = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // 统一加载所有关联数据
  Future<void> _loadAllData() async {
    setState(() {
      isLoading = true;
      errorMsg = "";
    });

    try {
      final futureMaterial = _fetchMaterialList();
      final futureScores = _fetchStudentAllScores();
      await Future.wait([futureMaterial, futureScores]);
    } catch (e) {
      setState(() {
        errorMsg = "加载失败：${e.toString().replaceAll('Exception: ', '')}";
      });
      print("数据加载异常：$e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 获取材料列表
  Future<void> _fetchMaterialList() async {
    final response = await get(
      "/query/materials/stu",
      queryParameters: {
        "page_num": currentPage,
        "page_size": pageSize,
        "Id": widget.studentId,
      },
    );

    Map<String, dynamic> responseData = response.data;
    if (responseData["base"]?["code"] == 10000) {
      setState(() {
        materialList = List<Map<String, dynamic>>.from(
          responseData["data"]?["items"] ?? [],
        );
        totalItems = responseData["data"]?["total"] ?? 0;
      });
    } else {
      throw Exception(
        responseData["base"]?["msg"] ?? "获取材料列表失败",
      );
    }
  }

  // 获取学生所有积分
  Future<void> _fetchStudentAllScores() async {
    final response = await get(
      "/query/score/stu",
      queryParameters: {
        "stu_id": widget.studentId,
      },
    );

    Map<String, dynamic> responseData = response.data;
    if (responseData["base"]?["code"] == 10000) {
      setState(() {
        Map<String, double> scoresMap = {};
        List<dynamic> scoreItems = responseData["data"]?["items"] ?? [];

        for (var scoreItem in scoreItems) {
          String eventId = scoreItem["event_id"] ?? "";
          double score = scoreItem["final_score"]?.toDouble() ?? 0;
          if (eventId.isNotEmpty) {
            scoresMap[eventId] = score;
          }
        }

        eventScores = scoresMap;
        totalScore = responseData["data"]?["sum"]?.toDouble() ?? 0;
      });
    } else {
      throw Exception(
        responseData["base"]?["msg"] ?? "获取积分数据失败",
      );
    }
  }

  // 分页切换
  void _changePage(int newPage) {
    if (newPage < 1 || newPage > (totalItems / pageSize).ceil()) return;
    setState(() {
      currentPage = newPage;
    });
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          '查询学生积分',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 学生信息展示框
              Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${widget.studentName}（学号：${widget.studentId}）",
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              // 加载状态
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                )
              // 错误状态
              else if (errorMsg.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMsg,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAllData,
                          child: const Text("重新加载"),
                        ),
                      ],
                    ),
                  ),
                )
              // 数据展示
              else
                Expanded(
                  child: Column(
                    children: [
                      // 表头（三列布局）
                      Container(
                        color: Colors.grey[100],
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          children: [
                            // 赛事名称（占比40%）
                            Expanded(
                              flex: 5,
                              child: const Text(
                                '赛事名称',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            // 识别信息（占比35%）
                            Expanded(
                              flex: 3,
                              child: const Text(
                                '识别信息',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            // 计算积分（占比25%）
                            Expanded(
                              flex: 3,
                              child: const Text(
                                '计算积分',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // 表格内容
                      Expanded(
                        child: materialList.isEmpty
                            ? const Center(child: Text("暂无积分数据"))
                            : ListView.builder(
                          itemCount: materialList.length,
                          itemBuilder: (context, index) {
                            final item = materialList[index];
                            final score = eventScores[item["event_id"]] ?? 0;

                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFE0E0E0)),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中对齐
                                children: [
                                  // 赛事名称（左对齐）
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      item["event_name"] ?? "未知赛事",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // 识别信息（居中对齐）
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min, // 最小高度，避免拉伸
                                      children: [
                                        Text(
                                          item["award_time"] ?? "未知时间",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          item["award_content"] ?? "未知奖项",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 计算积分（右对齐）
                                  Expanded(
                                    flex: 3,
                                    child: Align(
                                      alignment: Alignment.centerLeft, // 左对齐，与表头对应
                                      child: Text(
                                        score.toStringAsFixed(1), // 统一保留1位小数
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // 分页控件
                      if (totalItems > pageSize)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: currentPage > 1
                                    ? () => _changePage(currentPage - 1)
                                    : null,
                                child: const Text("上一页"),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "第 $currentPage 页 / 共 ${(totalItems / pageSize).ceil()} 页",
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: currentPage < (totalItems / pageSize).ceil()
                                    ? () => _changePage(currentPage + 1)
                                    : null,
                                child: const Text("下一页"),
                              ),
                            ],
                          ),
                        ),

                      // 总积分
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '总积分：${totalScore.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
