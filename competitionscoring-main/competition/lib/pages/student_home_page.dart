  // 学生个人主页页面

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'upload_page.dart';
import 'score_detail_page.dart';
import 'appeal_record_page.dart';
import 'package:competition/util/http.dart';
import 'package:competition/util/token_util.dart';


class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});
  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

  class _StudentHomePageState extends State<StudentHomePage> {
  // 存储用户信息
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    // 初始化时获取用户信息
    _fetchUserInfo();
  }

  // 获取用户信息
  Future<void> _fetchUserInfo() async {
    try {
      // 从本地存储获取userId（假设TokenUtil中有获取userId的方法）
      String? userId = await TokenUtil.getUserId();
      print(userId);
      if (userId == null || userId.isEmpty) {
        setState(() {
          isLoading = false;
          errorMsg = '未获取到用户信息';
        });
        return;
      }
      // 发送请求：使用封装的get方法，传入路径和路径参数
      final response = await get(
        '/users', // 路径模板
        queryParameters: {'Id': userId},
      );
      print(userId);
      if (response.statusCode == 200) {

        if (response.data['base']['code'] == 10000) {
          setState(() {
            userInfo = response.data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMsg = response.data['base']['msg'] ?? '获取用户信息失败';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMsg = '请求失败，状态码：${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = '获取信息出错：${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child:Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text('个人主页',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700,fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
  //顶部返回跳到登录页面
  onPressed: () {
    // 清除本地用户信息
    TokenUtil.clearTokens();
    Navigator.pushReplacementNamed(context, '/login');
  },
),

systemOverlayStyle: SystemUiOverlayStyle.dark, 
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          const SizedBox(height: 20),
          // 顶部个人信息卡
          Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius:10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
             
              mainAxisAlignment: MainAxisAlignment.center,//垂直居中
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      userInfo?['username'] ?? '未知用户',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '账号：${userInfo?['userId'] ?? '未知账号'}',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 菜单列表
          _buildMenuItem(
            context,
            icon: Icons.cloud_upload,
            color: Colors.blue,
            title: '赛事材料上传',
            page: const UploadPage(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.insert_chart_outlined,
            color: Colors.green,
            title: '个人积分明细',
            page: const ScoreDetailPage(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.description,
            color: Colors.orange,
            title: '申诉记录',
            page: const AppealRecordPage(),
          ),

          const SizedBox(height: 40),

          // 退出按钮
          Center(
            child: TextButton(
              //退出跳到登录页面
              onPressed: () {
                // 清除本地用户信息
                TokenUtil.clearTokens();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                '退出登录',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required Widget page}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}
