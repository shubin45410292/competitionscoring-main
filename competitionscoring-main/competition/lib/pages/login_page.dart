
// 登录页面(主页面)

import 'package:flutter/material.dart';
import 'package:competition/util/http.dart';
import 'package:competition/util/token_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final account = _accountController.text.trim();
    final password = _passwordController.text.trim();

    // 简单验证输入不为空
    if (account.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('账号或密码不能为空'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // 调用后端登录接口（使用封装的post方法）
      // 接口路径：/auth/login（会自动拼接baseUrl）
      var response = await post(
        "/auth/login",
        data: {
          "Id": account,
          "password": password,
        },
      );

      // 1. 打印完整响应头和响应体，确认格式（调试用）
      print("响应头：${response.headers}");
      print("响应体：${response.data}");

      // 2. 从响应头提取Token（根据调试结果，头字段是Access-Token和Refresh-Token）
      String? accessToken = response.headers.value("Access-Token");
      String? refreshToken = response.headers.value("Refresh-Token");

      // 3. 校验Token是否存在
      if (accessToken == null || refreshToken == null) {
        throw Exception("登录成功，但未获取到Token");
      }

      // 4. 保存Token到本地
      // 新增：提取userId（根据后端返回格式）
      String userId = response.data["data"]["userId"].toString();
      if (userId.isEmpty) {
        throw Exception("未获取到用户ID");
      }

      // 保存Token和userId到本地
      await TokenUtil.saveTokens(accessToken, refreshToken, userId);

      // 5. 处理响应体，判断登录状态和用户角色
      var responseData = response.data; // 响应体数据
      if (responseData["base"]["code"] == 10000) {
        String role = responseData["data"]["role"];
        switch (role) {
          case "counselor":
            Navigator.pushReplacementNamed(context, '/teacherHome');
            break;
          case "student":
            Navigator.pushReplacementNamed(context, '/studentHome');
            break;
          case "admin":
            Navigator.pushReplacementNamed(context, '/adminHome');
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('未知用户角色')),
            );
        }
      } else {
        // 后端返回错误信息（假设错误信息在responseData["msg"]）
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData["msg"] ?? "登录失败"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '用户登录',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 250,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '欢迎登录',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '账号',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _accountController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          hintText: 'teacher 或 student 或 admin',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '密码',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                          hintText: '123456',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text('注册', style: TextStyle(fontSize: 13))),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgotPassword');
                          },
                          child: const Text('忘记密码', style: TextStyle(fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('登录',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
