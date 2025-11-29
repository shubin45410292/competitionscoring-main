import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/http.dart'; // 导入封装的http工具
import 'student_award_detail_page.dart';

class StudentAwardPage extends StatefulWidget {
  const StudentAwardPage({Key? key}) : super(key: key);

  @override
  State<StudentAwardPage> createState() => _StudentAwardPageState();
}

class _StudentAwardPageState extends State<StudentAwardPage> {
  // 仅保留状态筛选选项（待审核、已审核、驳回、未被认定）
  final List<String> statusList = ["待审核", "已审核", "驳回", "未被认定"];
  String selectedStatus = "待审核"; // 默认选中待审核

  // 数据状态管理
  List<Map<String, dynamic>> awardList = [];
  bool isLoading = false;
  String errorMsg = "";
  int totalItems = 0;

  // 分页参数（接口支持分页，默认10条/页）
  int currentPage = 1;
  final int pageSize = 10;

  @override
  void initState() {
    super.initState();
    // 初始化加载数据
    _fetchAwardList();
  }

  // 加载奖项列表（对接后端接口：/admin/query/materials/stu）
  Future<void> _fetchAwardList() async {
    setState(() {
      isLoading = true;
      errorMsg = "";
    });

    try {
      // 构建请求参数
      Map<String, dynamic> queryParams = {
        "page_num": currentPage,
        "page_size": pageSize,
        "status": selectedStatus,
      };

      // 调用封装的get请求
      final response = await get(
        "/admin/query/materials/stu",
        queryParameters: queryParams,
      );

      Map<String, dynamic> responseData = response.data;
      if (responseData["base"]?["code"] == 10000) {
        setState(() {
          awardList = List<Map<String, dynamic>>.from(
            responseData["data"]?["items"] ?? [],
          );
          totalItems = responseData["data"]?["total"] ?? 0;
        });
      } else {
        throw Exception(
          responseData["base"]?["msg"] ?? "获取奖项列表失败",
        );
      }
    } catch (e) {
      setState(() {
        errorMsg = "加载失败：${e.toString().replaceAll('Exception: ', '')}";
      });
      print("获取奖项列表异常：$e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 审核操作（通过/驳回）
  Future<void> _handleExamine(String eventId, int result) async {
    setState(() {
      isLoading = true;
    });

    try {
      // 构建表单数据（接口要求form-data格式）
      FormData formData = FormData.fromMap({
        "event_id": eventId,
        "examine_results": result, // 1-通过，2-驳回
      });

      // 调用封装的postFormData方法发送请求
      final response = await postFormData(
        "/examine/materials",
        formData: formData,
      );

      Map<String, dynamic> responseData = response.data;
      if (responseData["base"]?["code"] == 10000) {
        // 审核成功后刷新列表
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result == 1 ? "审核通过成功" : "驳回成功"),
            backgroundColor: Colors.green,
          ),
        );
        _fetchAwardList(); // 刷新数据
      } else {
        throw Exception(
          responseData["base"]?["msg"] ?? "审核操作失败",
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("操作失败：${e.toString().replaceAll('Exception: ', '')}"),
          backgroundColor: Colors.red,
        ),
      );
      print("审核操作异常：$e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 切换状态筛选
  void _onStatusChanged(String? value) {
    if (value == null || value == selectedStatus) return;
    setState(() {
      selectedStatus = value;
      currentPage = 1; // 切换状态时重置页码
    });
    _fetchAwardList();
  }

  // 分页切换
  void _changePage(int newPage) {
    if (newPage < 1 || newPage > (totalItems / pageSize).ceil()) return;
    setState(() {
      currentPage = newPage;
    });
    _fetchAwardList();
  }

  // 打开详情页（传递event_id给详情页）
  void _openDetailPage(String eventId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => StudentAwardDetailPage(eventId: eventId), // 传递event_id
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          '学生申报奖项',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          /// 过滤条件区域（仅保留状态筛选）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildStatusDropDown(),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),

          /// 列表内容
          Expanded(
            child: _buildAwardListWidget(),
          ),

          /// 分页控件
          if (totalItems > pageSize && !isLoading && errorMsg.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: currentPage > 1
                        ? () => _changePage(currentPage - 1)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPage > 1 ? Colors.blue : Colors.grey,
                    ),
                    child: const Text("上一页", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "第 $currentPage 页 / 共 ${(totalItems / pageSize).ceil()} 页",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: currentPage < (totalItems / pageSize).ceil()
                        ? () => _changePage(currentPage + 1)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPage < (totalItems / pageSize).ceil() ? Colors.blue : Colors.grey,
                    ),
                    child: const Text("下一页", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 状态筛选下拉框
  Widget _buildStatusDropDown() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          hint: const Text("选择状态", style: TextStyle(color: Colors.grey)),
          items: statusList
              .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(fontSize: 14)),
          ))
              .toList(),
          onChanged: _onStatusChanged,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ),
      ),
    );
  }

  /// 奖项列表展示组件
  Widget _buildAwardListWidget() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    } else if (errorMsg.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMsg, style: const TextStyle(color: Colors.red, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAwardList,
              child: const Text("重新加载"),
            ),
          ],
        ),
      );
    } else if (awardList.isEmpty) {
      return const Center(child: Text("暂无相关奖项申报数据", style: TextStyle(color: Colors.grey)));
    } else {
      return ListView.builder(
        itemCount: awardList.length,
        itemBuilder: (context, index) => _buildAwardCard(awardList[index]),
      );
    }
  }

  /// 奖项卡片 UI
  Widget _buildAwardCard(Map<String, dynamic> awardData) {
    // 解析后端数据
    String eventId = awardData["event_id"] ?? ""; // 获取event_id
    String eventName = awardData["event_name"] ?? "未知赛事";
    String awardTime = awardData["award_time"] ?? "未知时间";
    String awardLevel = awardData["award_level"] ?? "未知奖项";
    String eventLevel = awardData["event_level"] ?? "未知级别";
    String userId = awardData["user_id"] ?? "未知用户";
    String status = awardData["material_status"] ?? "未知状态";

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 赛事名称
          Text(
            eventName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          // 详情信息
          _buildInfoText("赛事级别：$eventLevel"),
          _buildInfoText("识别信息：$awardTime $awardLevel"),
          _buildInfoText("申报人学号：$userId"),
          _buildInfoText("当前状态：${_getStatusText(status)}"),
          const SizedBox(height: 6),
          // 查看详情（传递event_id）
          GestureDetector(
            onTap: () => _openDetailPage(eventId),
            child: const Text(
              "查看",
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // 操作按钮（仅待审核状态显示）
          if (status == "待审核")
            Row(
              children: [
                _buildActionButton("通过", Colors.green, () {
                  // 调用审核接口（1-通过）
                  if (eventId.isNotEmpty) {
                    _handleExamine(eventId, 1);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("缺少赛事ID，无法操作"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }),
                const SizedBox(width: 12),
                _buildActionButton("驳回", Colors.red, () {
                  // 调用审核接口（2-驳回）
                  if (eventId.isNotEmpty) {
                    _handleExamine(eventId, 2);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("缺少赛事ID，无法操作"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }),
              ],
            ),
        ],
      ),
    );
  }

  /// 信息文本组件
  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// 操作按钮组件
  Widget _buildActionButton(String text, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 状态文本格式化
  String _getStatusText(String status) {
    switch (status) {
      case "待审核":
        return "待审核";
      case "已审核":
        return "已审核";
      case "驳回":
        return "已驳回";
      case "未被认定":
        return "未被认定";
      default:
        return status;
    }
  }
}
