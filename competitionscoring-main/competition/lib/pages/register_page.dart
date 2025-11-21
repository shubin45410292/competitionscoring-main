// 用户注册页面(主页面)

import 'package:flutter/material.dart';
import 'package:competition/util/http.dart';

class UserRegisterPage extends StatefulWidget {
  const UserRegisterPage({super.key});

  @override
  State<UserRegisterPage> createState() => _UserRegisterPageState();
}

class _UserRegisterPageState extends State<UserRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isCodeSent = false;


  //  //测试用
  // void _sendVerificationCode() {
  //   final email = _emailController.text.trim();
  //   if (email.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('请输入邮箱地址')));
  //     return;
  //   }
  //
  //   setState(() {
  //     _isCodeSent = true;
  //   });
  //
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text('验证码已发送至 $email')));
  // }

  // //测试用
  // void _submit() {
  //   final email = _emailController.text.trim();
  //   final code = _codeController.text.trim();
  //   final name = _nameController.text.trim();
  //   final id = _idController.text.trim();
  //   final password = _passwordController.text.trim();
  //   final confirmPassword = _confirmPasswordController.text.trim();
  //
  //   if (email.isEmpty ||
  //       code.isEmpty ||
  //       password.isEmpty ||
  //       confirmPassword.isEmpty ||
  //       name.isEmpty ||
  //       id.isEmpty
  //   ) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('请填写所有字段')));
  //     return;
  //   }
  //
  //   if (password != confirmPassword) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('两次输入的密码不一致')));
  //     return;
  //   }
  //
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text('注册成功，请返回登录')));
  //
  //   Navigator.pop(context);
  // }

  void _sendVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入邮箱地址')),
      );
      return;
    }

    try {
      // 调用发送邮箱验证码接口（POST /auth/email/send）
      var response = await post(
        "/auth/email/send",
        data: {
          "email": email, // 对应接口的email参数
        },
      );

      // 根据后端响应处理（参考接口返回格式：{"base": {"code": 10000, "msg": "success"}}）
      if (response.data["base"]["code"] == 10000) {
        setState(() => _isCodeSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('验证码已发送至 $email')),
        );
      } else {
        // 后端返回错误提示（如邮箱格式错误）
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data["base"]["msg"] ?? "发送验证码失败"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // 网络错误处理
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final name = _nameController.text.trim();
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 本地输入验证
    if (email.isEmpty || code.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有字段')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('两次输入的密码不一致')),
      );
      return;
    }

    try {
      // 1. 先验证邮箱验证码（POST /auth/email）
      var verifyResponse = await post(
        "/auth/email",
        data: {
          "code": code,   // 验证码
          "email": email, // 邮箱地址
        },
      );

      if (verifyResponse.data["base"]["code"] != 10000) {
        // 验证码验证失败
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verifyResponse.data["base"]["msg"] ?? "验证码错误"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // 2. 验证成功后，提交注册信息（POST /auth/register）
      var registerResponse = await post(
        "/auth/register",
        data: {
          "username": name,   // 姓名（对应接口的username参数）
          "password": password, // 密码
          "email": email,     // 邮箱
          "id": id,           // 学号（对应接口的id参数）
        },
      );

      if (registerResponse.data["base"]["code"] == 10000) {
        // 注册成功
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注册成功，请返回登录')),
        );
        Navigator.pop(context); // 返回登录页
      } else {
        // 注册失败（如学号已存在）
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(registerResponse.data["base"]["msg"] ?? "注册失败"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      // 网络错误处理
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
            width: 320,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '用户注册',
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
                        '欢迎注册',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    //姓名
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '姓名',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请输入姓名',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    //学号
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '学号',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '请输入学号',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        suffix: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: _isCodeSent
                                ? null
                                : _sendVerificationCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text('获取验证码'),
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
                        hintText: '请输入密码',
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('登录', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          '注册',
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
