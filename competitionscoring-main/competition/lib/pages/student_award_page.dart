import 'package:flutter/material.dart';
import 'student_award_detail_page.dart';

class StudentAwardPage extends StatefulWidget {
  const StudentAwardPage({Key? key}) : super(key: key);

  @override
  State<StudentAwardPage> createState() => _StudentAwardPageState();
}

class _StudentAwardPageState extends State<StudentAwardPage> {
  // 下拉选项
  List<String> years = ["2024–2025", "2023–2024", "2022–2023"];
  List<String> levels = ["全部", "院级", "校级", "省级", "国家级"];
  List<String> statusList = ["待审批", "通过", "驳回"];

  String selectedYear = "2024–2025";
  String selectedLevel = "全部";
  String selectedStatus = "待审批";

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

          /// ------------------------------- 过滤条件区域 ------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildDropDown(
                  label: "学年",
                  value: selectedYear,
                  items: years,
                  hintText: "请选择学年",
                  onChanged: (v) => setState(() => selectedYear = v!),
                ),
                const SizedBox(width: 8),
                _buildDropDown(
                  label: "赛事级别",
                  value: selectedLevel,
                  items: levels,
                  hintText: "选择赛事级别",
                  onChanged: (v) => setState(() => selectedLevel = v!),
                ),
                const SizedBox(width: 8),
                _buildDropDown(
                  label: "状态",
                  value: selectedStatus,
                  items: statusList,
                  hintText: "选择状态",
                  onChanged: (v) => setState(() => selectedStatus = v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),

          /// --------------------------------- 列表内容 --------------------------------
          Expanded(
            child: ListView(
              children: [
                _buildAwardCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ====================== 奖项卡片 UI ==========================
  Widget _buildAwardCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "全国大学生数学建模竞赛",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          _buildInfoText("申报时间：2024-09-16"),
          _buildInfoText("识别信息：2024-09-15 团队一等奖"),
          _buildInfoText("积分：16"),
          _buildInfoText("申报人：小明"),

          const SizedBox(height: 6),

          GestureDetector(
            onTap: _openDetailPage,
            child: const Text(
              "查看",
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _buildActionButton("通过", Colors.green, () {}),
              const SizedBox(width: 12),
              _buildActionButton("驳回", Colors.red, () {}),
            ],
          ),
        ],
      ),
    );
  }

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
            ),
          ),
        ),
      ),
    );
  }

  /// ====================== 下拉筛选组件 ==========================
  Widget _buildDropDown({
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Expanded(
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(
              hintText,
              style: const TextStyle(color: Colors.grey),
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  /// ======================== 打开详情页 ==========================
  void _openDetailPage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, // ← 重点：不透明
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => const StudentAwardDetailPage(),
    );
  }
}
