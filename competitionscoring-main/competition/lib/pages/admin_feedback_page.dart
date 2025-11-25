import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_home_page.dart'; // 导入 AdminHomePage

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  State<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends State<AdminFeedbackPage> {
  String selectedYear = '2024–2025';
  String selectedStatus = '待回复';

  final List<Map<String, dynamic>> feedbackList = [
    {
      "title": "文件上传失败!",
      "time": "2025-8-8 12:41:42",
      "feedbackId": "102300000",
      "reply": "感谢建议，我们会在下个版本改进",
      "isReplied": true,
      "showInput": false,
      "controller": TextEditingController()
    },
    {
      "title": "xxxxxxxxxxx!",
      "time": "",
      "feedbackId": "",
      "reply": "",
      "isReplied": false,
      "showInput": false,
      "controller": TextEditingController()
    },
    {
      "title": "xxxxxxxxxxx!",
      "time": "",
      "feedbackId": "",
      "reply": "",
      "isReplied": false,
      "showInput": false,
      "controller": TextEditingController()
    },
  ];

  @override
  void dispose() {
    for (var item in feedbackList) {
      item["controller"].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4A90E2);
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryBlue,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminHomePage()),
              );
            },
          ),
          title: const Text(
            '用户反馈管理',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: Column(
          children: [
            // 顶部筛选区域
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              color: Colors.white,
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  // 年份下拉框
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: (screenWidth - 54) / 2),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedYear,
                          items: ['2023–2024', '2024–2025', '2025–2026']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Center(
                                      child: Text(e, style: const TextStyle(fontSize: 12)),
                                    ),
                                  ))
                              .toList(),
                          selectedItemBuilder: (context) => ['2023–2024', '2024–2025', '2025–2026']
                              .map((e) => Center(
                                    child: Text('年份：$e', style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => selectedYear = v!),
                        ),
                      ),
                    ),
                  ),
                  // 状态下拉框
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: (screenWidth - 54) / 2),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedStatus,
                          items: ['待回复', '已回复']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Center(
                                      child: Text(e, style: const TextStyle(fontSize: 12)),
                                    ),
                                  ))
                              .toList(),
                          selectedItemBuilder: (context) => ['待回复', '已回复']
                              .map((e) => Center(
                                    child: Text('状态：$e', style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => selectedStatus = v!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                itemCount: feedbackList.length,
                itemBuilder: (context, index) {
                  final item = feedbackList[index];
                  return _buildFeedbackCard(item);
                },
              ),
            ),
            // 底部状态栏
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now()),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const Text(
                    '系统版本v2.3.1｜服务状态：正常',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> item) {
    bool isReplied = item["isReplied"] ?? false;
    bool showInput = item["showInput"] ?? false;
    TextEditingController controller = item["controller"];
    const Color primaryBlue = Color(0xFF4A90E2);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item["title"] ?? "", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (item["time"] != "") ...[
            const SizedBox(height: 6),
            Text("申请时间：${item["time"]}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
            Text("申请Id：${item["feedbackId"]}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ],
          if (isReplied) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(right: 70),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text("管理员回复： ${item["reply"]}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ),
          ],
          if (showInput) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(right: 70),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '回复:文本输入......',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                ),
                style: const TextStyle(fontSize: 13),
                maxLines: null,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                if (!isReplied) {
                  if (showInput) {
                    if (controller.text.trim().isNotEmpty) {
                      // 有内容 → 提交
                      setState(() {
                        item["reply"] = controller.text.trim();
                        item["isReplied"] = true;
                        item["showInput"] = false;
                      });
                    } else {
                      // 没有内容 → 取消输入框
                      setState(() {
                        item["showInput"] = false;
                      });
                    }
                  } else {
                    // 点击按钮显示输入框
                    setState(() {
                      item["showInput"] = true;
                      controller.text = '';
                    });
                  }
                }
              },
              child: Container(
                width: 90,
                height: 38,
                decoration: BoxDecoration(
                  color: isReplied ? primaryBlue : Colors.amber,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    isReplied ? "已回复" : "回复",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
