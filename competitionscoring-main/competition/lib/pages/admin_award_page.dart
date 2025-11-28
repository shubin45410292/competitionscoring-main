//奖项认定信息管理页面(管理员端)

import 'package:competition/util/createAwardDialog.dart';
import 'package:competition/util/editAwardDialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/token_util.dart';
import 'package:competition/util/http.dart';

// 页面主体
class AdminAwardPage extends StatefulWidget {
  const AdminAwardPage({super.key});

  @override
  State<AdminAwardPage> createState() => _AdminAwardPageState();
}

class _AdminAwardPageState extends State<AdminAwardPage> {
  int currentPage = 1;
  final int pageSize = 190; // 固定每页190条
  int totalPage = 1;
  int totalItems = 0;

  List<Map<String, dynamic>> awardList = [];
  bool isLoading = true; // 加载状态
  String errorMsg = ""; // 错误信息
  final TextEditingController _searchController =
      TextEditingController(); // 搜索控制器

  // 接口路径（拼接baseUrl后完整路径：http://204.152.192.27:8080/api/admin/reward/query）
  static const String awardQueryPath = "/admin/reward/query";

  @override
  void initState() {
    super.initState();
    // 页面初始化时请求数据
    fetchAwardData();
  }

  // 请求奖项数据
  Future<void> fetchAwardData({String? searchKeyword}) async {
    setState(() {
      isLoading = true;
      errorMsg = "";
    });

    try {
      // 构建请求参数
      Map<String, dynamic> queryParams = {
        "page_size": pageSize,
        "page_num": currentPage,
      };

      // 如果有搜索关键词，添加到参数中（根据后端是否支持搜索参数调整）
      if (searchKeyword != null && searchKeyword.isNotEmpty) {
        queryParams["keyword"] = searchKeyword; // 假设后端用keyword接收搜索参数
      }

      // 发送GET请求
      Response response = await get(
        awardQueryPath,
        queryParameters: queryParams,
      );

      // 解析响应数据
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;

        // 检查后端返回状态码
        if (responseData["base"]?["code"] == 10000) {
          List<dynamic> items = responseData["data"]?["item"] ?? [];

          // 转换数据格式（按照给定的对应关系）
          List<Map<String, dynamic>> formattedList = items.map((item) {
            return {
              "title": item["event_name"] ?? "未知奖项",
              "college": item["college"] ?? "未知学院",
              "organizer": item["organizer"] ?? "未知主办单位",
              "time": item["event_time"] ?? "未知时间",
              "major": item["related_majors"] ?? "不限",
              "applyMajor": item["applicable_majors"] ?? "不限",
              "certUnit": item["recognition_basis"] ?? "无",
              "level": item["recognized_level"] ?? "未知级别",
              "expanded": item["is_active"] ?? false,
              "recognize_reward_id":
                  item["recognize_reward_id"] ?? "", // 保存ID用于后续编辑/删除
            };
          }).toList();

          setState(() {
            awardList = formattedList;
            totalItems = formattedList.length; // 实际项目中应该用后端返回的total字段
            totalPage = (totalItems / pageSize).ceil(); // 计算总页数
          });
        } else {
          setState(() {
            errorMsg = "请求失败：${responseData["base"]?["msg"] ?? "未知错误"}";
          });
        }
      } else {
        setState(() {
          errorMsg = "请求失败，状态码：${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = "加载失败";
      });
      print("奖项数据请求异常：$e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 搜索功能
  void handleSearch() {
    String keyword = _searchController.text.trim();
    setState(() {
      currentPage = 1; // 搜索后重置到第一页
    });
    fetchAwardData(searchKeyword: keyword);
  }

  // -----------------------
  //  统一按钮样式 (扁平白底 + 描边)
  // -----------------------
  ButtonStyle outlineBtn(Color color) {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: color, width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  // 主按钮样式
  ButtonStyle primaryBtn() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2C70F5),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4A90E2);
    const Color bgColor = Color(0xFFF7F8FA);

    String formattedDate = DateFormat(
      'yyyy年MM月dd日 HH:mm',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "奖项认定信息管理",
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

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 搜索框（添加搜索功能）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search),
                  border: InputBorder.none,
                  hintText: "搜索奖项名称",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      handleSearch(); // 清空搜索
                    },
                  ),
                ),
                onSubmitted: (_) => handleSearch(), // 按回车搜索
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 加载状态、错误状态、数据展示
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  )
                : errorMsg.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMsg,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => fetchAwardData(),
                          style: outlineBtn(primaryBlue),
                          child: const Text(
                            "重新加载",
                            style: TextStyle(color: primaryBlue),
                          ),
                        ),
                      ],
                    ),
                  )
                : awardList.isEmpty
                ? const Center(child: Text("暂无奖项数据"))
                : ListView.builder(
                    itemCount: awardList.length,
                    itemBuilder: (context, index) {
                      var item = awardList[index];
                      bool expanded = item["expanded"] ?? false;

                      return Column(
                        children: [
                          // 标题行
                          ListTile(
                            title: Text(
                              item["title"],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_drop_down),
                            onTap: () {
                              setState(() {
                                item["expanded"] = !expanded;
                              });
                            },
                          ),

                          // 展开区块
                          if (expanded && item.containsKey('college'))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              color: Colors.grey.shade50,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("学院：${item["college"]}"),
                                  const SizedBox(height: 4),
                                  Text("主办单位：${item["organizer"]}"),
                                  const SizedBox(height: 4),
                                  Text("竞赛时间：${item["time"]}"),
                                  const SizedBox(height: 4),
                                  Text("涉及专业：${item["major"]}"),
                                  const SizedBox(height: 4),
                                  Text("申请专业：${item["applyMajor"]}"),
                                  const SizedBox(height: 4),
                                  Text("认定依据：${item["certUnit"]}"),
                                  const SizedBox(height: 4),
                                  Text("认定级别：${item["level"]}"),
                                  const SizedBox(height: 10),

                                  // 按钮（编辑 + 删除）
                                  // 按钮（编辑 + 删除）
                                  Row(
                                    children: [
                                      // 编辑按钮（保留原有）
                                      ElevatedButton(
                                        onPressed: () {
                                          // 编辑逻辑：传入奖项ID
                                          print("编辑奖项ID：${item["recognize_reward_id"]}");
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.white,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(18),
                                              ),
                                            ),
                                            builder: (_) => const EditAwardDialog(), // 修改用户信息组件
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[600],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        ),
                                        child: const Text(
                                          "编辑",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // 删除按钮（修正后，仅保留一个删除按钮）
                                      ElevatedButton(
                                        onPressed: () async {
                                          // 1. 删除确认弹窗
                                          bool confirm = await showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("确认删除"),
                                              content: const Text("确定要删除该奖项吗？此操作不可撤销。"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text("取消"),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text(
                                                    "删除",
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm) {
                                            // 2. 执行删除请求
                                            try {
                                              // 获取奖项ID并校验
                                              String rewardId = item["recognize_reward_id"] ?? "";
                                              if (rewardId.isEmpty) {
                                                throw Exception("奖项ID为空，无法删除");
                                              }

                                              // 3. 调用封装的delete方法，通过form-data传递参数

                                              // 调用封装的delete方法，传入接口路径和form-data参数
                                              final responseData = await delete(
                                                "/admin/reward/delete", // 接口路径（baseUrl已自动拼接）
                                                params: {
                                                  "recognize_reward_id": rewardId, // 必传参数：奖项ID
                                                },
                                              );

                                              // 4. 解析响应（后端返回格式：{"base": {"code": 10000, "msg": "success"}}）
                                              if (responseData is Map && responseData["base"]?["code"] == 10000) {
                                                // 删除成功：提示并刷新列表
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("删除成功")),
                                                  );
                                                }
                                                fetchAwardData(); // 重新加载数据
                                              } else {
                                                // 后端返回业务错误
                                                throw Exception(
                                                    responseData is Map
                                                        ? responseData["base"]??["msg"] ?? "删除失败"
                                                        : "删除失败"
                                                );
                                              }
                                            } catch (e) {
                                              // 错误处理（网络异常、参数错误等）
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("删除失败：${e.toString().replaceAll('Exception: ', '')}"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red, // 删除按钮用红色更直观
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        ),
                                        child: const Text(
                                          '删除',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),

                          const Divider(height: 1, color: Colors.grey),
                        ],
                      );
                    },
                  ),
          ),

          // 新建按钮
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
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
          builder: (_) => const CreateAwardDialog(),
        );
                // 新建奖项逻辑：跳转到新建页面或打开新建弹窗
                print("新建奖项");
              },
              style: primaryBtn(),
              child: const Text(
                "新建",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 分页（根据实际总页数动态显示）
          if (totalPage > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: currentPage > 1
                        ? () {
                            setState(() => currentPage--);
                            fetchAwardData(
                              searchKeyword: _searchController.text.trim(),
                            );
                          }
                        : null,
                    style: outlineBtn(const Color(0xFFCCCCCC)),
                    child: const Text(
                      "上一页",
                      style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                    ),
                    //enabled: currentPage > 1,
                  ),
                  const SizedBox(width: 20),
                  Text("$currentPage / $totalPage"),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: currentPage < totalPage
                        ? () {
                            setState(() => currentPage++);
                            fetchAwardData(
                              searchKeyword: _searchController.text.trim(),
                            );
                          }
                        : null,
                    style: outlineBtn(const Color(0xFFCCCCCC)),
                    child: const Text(
                      "下一页",
                      style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                    ),
                    //enabled: currentPage < totalPage,
                  ),
                ],
              ),
            ),

          // 底部状态栏
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "$formattedDate     系统版本v2.3.1 ｜ 服务状态：正常",
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
