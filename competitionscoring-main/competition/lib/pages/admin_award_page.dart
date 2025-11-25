//奖项认定信息管理页面(管理员端)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminAwardPage extends StatefulWidget {
  const AdminAwardPage({super.key});

  @override
  State<AdminAwardPage> createState() => _AdminAwardPageState();
}

class _AdminAwardPageState extends State<AdminAwardPage> {
  int currentPage = 1;
  int totalPage = 5;

  List<Map<String, dynamic>> awardList = [
    {
      "title": "“台达杯”高校自动化设计大赛",
      "college": "电气",
      "organizer": "中国自动化学会",
      "time": "每年7月至8月",
      "major": "不限",
      "applyMajor": "自动化",
      "certUnit": "国家级学会、教育部专业教学指导委员会",
      "level": "国家级",
      "expanded": true
    },
    {
      "title": "全国大学生数学建模竞赛",
      "expanded": false
    }
  ];

  // -----------------------
  //  统一按钮样式 (扁平白底 + 描边)
  // -----------------------

  ButtonStyle outlineBtn(Color color) {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: color, width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  // 主按钮样式
  ButtonStyle primaryBtn() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2C70F5),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4A90E2);
    const Color bgColor = Color(0xFFF7F8FA);
    const double cardRadius = 12;
    
    String formattedDate =
        DateFormat('yyyy年MM月dd日 HH:mm').format(DateTime.now());

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

          // 搜索框
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
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  border: InputBorder.none,
                  hintText: "搜索奖项名称",
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
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
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
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
                            horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("学院：${item["college"]}"),
                            Text("主办单位：${item["organizer"]}"),
                            Text("竞赛时间：${item["time"]}"),
                            Text("涉及专业：${item["major"]}"),
                            Text("申请专业：${item["applyMajor"]}"),
                            Text("认定依据：${item["certUnit"]}"),
                            Text("认定级别：${item["level"]}"),

                            const SizedBox(height: 10),

                            // 按钮（编辑 + 删除）
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {},
                                  style: outlineBtn(const Color(0xFF2C70F5)),
                                  child: const Text(
                                    "编辑",
                                    style: TextStyle(
                                      color: Color(0xFF2C70F5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                OutlinedButton(
                                  onPressed: () {},
                                  style: outlineBtn(Colors.red),
                                  child: const Text(
                                    "删除",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const Divider(height: 1),
                  ],
                );
              },
            ),
          ),

          // 新建按钮
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: () {},
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

          // 分页
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: currentPage > 1
                      ? () => setState(() => currentPage--)
                      : null,
                  style: outlineBtn(const Color(0xFFCCCCCC)),
                  child: const Text(
                    "上一页",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Text("$currentPage / $totalPage"),
                const SizedBox(width: 20),
                OutlinedButton(
                  onPressed: currentPage < totalPage
                      ? () => setState(() => currentPage++)
                      : null,
                  style: outlineBtn(const Color(0xFFCCCCCC)),
                  child: const Text(
                    "下一页",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
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
          )
        ],
      ),
    );
  }
}
