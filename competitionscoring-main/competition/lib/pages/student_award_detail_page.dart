import 'package:flutter/material.dart';

class StudentAwardDetailPage extends StatefulWidget {
  const StudentAwardDetailPage({Key? key}) : super(key: key);

  @override
  State<StudentAwardDetailPage> createState() => _StudentAwardDetailPageState();
}

class _StudentAwardDetailPageState extends State<StudentAwardDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white, // ← 不透明背景
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------------- 顶部标题 ----------------
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

          /// ---------------- Tab ----------------
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

          /// ---------------- 内容区 ----------------
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
    );
  }

  /// ================== 1. 基础信息 ==================
  Widget _buildBaseInfo() {
    return ListView(
      children: [
        _infoRow("赛事名称", "全国大学生数学建模竞赛"),
        _infoRow("申报时间", "2024-09-16"),
        _infoRow("识别信息", "团队一等奖"),
        _infoRow("积分", "16"),
        _infoRow("申报人", "小明"),
        _infoRow("审核状态", "待审批"),
      ],
    );
  }

  /// ================== 2. 赛事信息 ==================
  Widget _buildCompetitionInfo() {
    return ListView(
      children: [
        _infoRow("赛事级别", "国家级"),
        _infoRow("主办单位", "中国工业与应用数学学会"),
        _infoRow("举办时间", "2024-09-10 ～ 2024-09-15"),
        _infoRow("团队人数", "3"),
        _infoRow("团队角色", "队长"),
      ],
    );
  }

  /// ================== 3. 文件记录 ==================
  Widget _buildFiles() {
    return ListView(
      children: [
        _fileItem("获奖证书.pdf"),
        _fileItem("作品说明书.docx"),
        _fileItem("团队合照.jpg"),
      ],
    );
  }

  /// --------------------- 通用信息行 ---------------------
  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
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
            ),
          ),
        ],
      ),
    );
  }

  /// --------------------- 文件行 ---------------------
  Widget _fileItem(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("查看"),
          )
        ],
      ),
    );
  }
}
