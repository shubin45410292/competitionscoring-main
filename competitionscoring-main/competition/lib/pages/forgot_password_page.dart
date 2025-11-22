// 忘记密码页面(主页面)
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/http.dart'; // 导入封装的http工具类（确保路径正确）

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isCodeSent = false;
  bool _isLoading = false; // 添加加载状态，防止重复请求

  // 发送验证码（调用后端 /auth/email/send 接口）
  void _sendVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入邮箱地址')));
      return;
    }

    setState(() => _isLoading = true); // 开始加载

    try {
      // 调用后端发送验证码接口：POST /auth/email/send
      final response = await post(
        "/auth/email/send",
        data: {"email": email}, // 按后端要求传递邮箱参数
      );
      print("发送验证码");
      print(response);
      if (response.data["base"]["code"] == 10000) {
        setState(() => _isCodeSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('验证码已发送至 $email，请查收')),
        );
      } else {
        // 后端返回错误信息
        String errMsg = response.data["base"]["message"] ?? "发送验证码失败";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errMsg)));
      }
    } catch (e) {
      // 捕获网络错误或接口异常
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('发送失败：${e.toString()}')));
    } finally {
      setState(() => _isLoading = false); // 结束加载
    }
  }

  // 提交重置密码（先验证验证码，再修改密码）
  void _submit() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 前端基础校验
    if (email.isEmpty || code.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请填写所有字段')));
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('两次输入的密码不一致')));
      return;
    }
    // 密码强度校验（可选，根据需求添加）
    if (password.length < 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('密码长度不能少于6位')));
      return;
    }

    setState(() => _isLoading = true); // 开始加载

    try {
      // // 第一步：验证验证码（调用后端 /auth/email 接口）
      // final verifyResponse = await post(
      //   "/auth/email",
      //   data: {"email": email, "code": code}, // 传递邮箱和验证码
      // );
      //
      // if (verifyResponse.data["base"]["code"] != 10000) {
      //   String errMsg = verifyResponse.data?["message"] ?? "验证码验证失败";
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text(errMsg)));
      //   return;
      // }
      List<String> parts = email.split('@');
      // 取数组第一个元素（邮箱前缀）
      String prefix = parts[0];
      // 第二步：验证码通过后，调用修改密码接口（put /update/user/password）
      final updateResponse = await put(
        "/update/user/password",
        data: {
          "email": email, // 后端可能需要邮箱作为用户标识
          "code": code,   // 部分后端会二次校验验证码
          "password": password, // 新密码
          "user_id": prefix,
        },
      );
      print("重置密码");
      print(updateResponse);
      if (updateResponse.data["base"]["code"] == 10000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码已重置，请返回登录')),
        );
        Navigator.pop(context); // 返回登录页
      } else {
        String errMsg = updateResponse.data?["message"] ?? "修改密码失败";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errMsg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('操作失败：${e.toString()}')));
    } finally {
      setState(() => _isLoading = false); // 结束加载
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
            width: 320,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '找回密码',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '我们将向您的邮箱发送验证码',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 邮箱
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '邮箱',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请输入邮箱地址',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                      ),
                      enabled: !_isCodeSent, // 发送验证码后禁用邮箱输入
                    ),
                    const SizedBox(height: 16),

                    // 验证码
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '请输入验证码',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: '请输入验证码',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                        // 右侧获取验证码按钮
                        suffix: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: (_isCodeSent || _isLoading)
                                ? null
                                : _sendVerificationCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text('获取验证码'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 密码
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '密码',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请输入新密码',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 再次输入密码
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '再次输入密码',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请再次输入密码',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('登录', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 提交按钮
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          '提交',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
