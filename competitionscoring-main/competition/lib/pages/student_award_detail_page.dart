import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 导入url_launcher用于打开链接
import 'package:competition/util/http.dart';

class StudentAwardDetailPage extends StatefulWidget {
  final String eventId;

  const StudentAwardDetailPage({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<StudentAwardDetailPage> createState() => _StudentAwardDetailPageState();
}

class _StudentAwardDetailPageState extends State<StudentAwardDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? baseInfo;
  bool isLoading = true;
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
    );
    // 延迟请求数据，避免与 BottomSheet 动画冲突
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBaseInfo();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBaseInfo() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMsg = "";
      });
    }

    try {
      final response = await get(
        "/query/materials/single",
        queryParameters: {"event_id": widget.eventId},
      );

      Map<String, dynamic> responseData = response.data;
      if (responseData["base"]?["code"] == 10000) {
        if (mounted) {
          setState(() {
            baseInfo = responseData["data"] ?? {};
            isLoading = false;
          });
        }
      } else {
        throw Exception(
          responseData["base"]?["msg"] ?? "获取基础信息失败",
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = "加载失败：${e.toString().replaceAll('Exception: ', '')}";
          isLoading = false;
        });
      }
      print("详情页数据请求失败：$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 顶部标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "奖项详情",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),

            const SizedBox(height: 10),

            /// 统一使用 Stack 管理状态
            Expanded(
              child: Stack(
                children: [
                  // 内容区域
                  if (!isLoading && errorMsg.isEmpty && baseInfo != null)
                    Column(
                      children: [
                        /// Tab栏
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black87,
                            tabs: const [
                              Tab(text: "基础信息"),
                              Tab(text: "赛事信息"),
                              Tab(text: "文件记录"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// Tab内容区
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildBaseInfo(),
                              _buildCompetitionInfo(),
                              _buildFiles(),
                            ],
                          ),
                        ),
                      ],
                    ),

                  // 加载状态
                  if (isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.blue)),

                  // 错误状态
                  if (!isLoading && errorMsg.isNotEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(errorMsg, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchBaseInfo,
                            child: const Text("重新加载"),
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
    );
  }

  /// 基础信息 Tab（无修改）
  Widget _buildBaseInfo() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return _infoRow("赛事名称", baseInfo?["event_name"] ?? "未知");
          case 1:
            return _infoRow("申报人学号", baseInfo?["user_id"] ?? "未知");
          case 2:
            return _infoRow("获奖时间", baseInfo?["award_time"] ?? "未知");
          case 3:
            return _infoRow("获奖等级", baseInfo?["award_level"] ?? "未知");
          case 4:
            return _infoRow("审核状态", baseInfo?["material_status"] ?? "未知");
          case 5:
            return _infoRow("创建时间", _formatTimestamp(baseInfo?["created_at"]));
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  /// 赛事信息 Tab（移除「赛事影响力」字段）
  Widget _buildCompetitionInfo() {
    // 移除赛事影响力后，itemCount改为5
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return _infoRow("赛事ID", baseInfo?["event_id"] ?? "未知");
          case 1:
            return _infoRow("赛事级别", baseInfo?["event_level"] ?? "未知");
          case 2:
            return _infoRow("主办单位", baseInfo?["event_organizer"] ?? "未知");
          case 3:
            return _infoRow("自动识别", baseInfo?["auto_extracted"] == true ? "是" : "否");
          case 4:
            return _infoRow("最后更新时间", _formatTimestamp(baseInfo?["updated_at"]));
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  /// 文件记录 Tab（直接使用后端返回的material_url）
  Widget _buildFiles() {
    final materialUrl = baseInfo?["material_url"] ?? "";
    // 从URL中提取文件名（如果URL有后缀）
    final fileName = _extractFileNameFromUrl(materialUrl);

    return ListView(
      children: [
        if (materialUrl.isNotEmpty)
          _fileItem(
            name: fileName,
            url: materialUrl,
          )
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text("暂无相关文件", style: TextStyle(color: Colors.grey)),
            ),
          ),
      ],
    );
  }

  /// 通用信息行组件
  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 文件行组件（点击查看直接打开后端返回的链接）
  Widget _fileItem({required String name, required String url}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          TextButton(
            onPressed: () async {
              // 直接打开后端返回的材料链接
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication, // 用外部浏览器打开
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("无法打开该链接")),
                );
              }
            },
            child: const Text("查看"),
          )
        ],
      ),
    );
  }

  /// 从URL中提取文件名（优化显示）
  String _extractFileNameFromUrl(String url) {
    if (url.isEmpty) return "获奖证明材料";
    try {
      // 截取URL中最后一个"/"后的部分
      final lastSlashIndex = url.lastIndexOf("/");
      if (lastSlashIndex != -1 && lastSlashIndex < url.length - 1) {
        String fileName = url.substring(lastSlashIndex + 1);
        // 移除URL中的特殊字符（如时间戳、参数等）
        fileName = fileName.split("?").first; // 去掉参数部分
        fileName = fileName.split("%20").join(" "); // 替换空格编码
        return fileName.isNotEmpty ? fileName : "获奖证明材料";
      }
      return "获奖证明材料";
    } catch (e) {
      return "获奖证明材料";
    }
  }

  /// 时间戳格式化
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null || timestamp.toString().isEmpty) {
      return "未知";
    }
    try {
      final int seconds = int.parse(timestamp.toString());
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return timestamp.toString();
    }
  }
}
