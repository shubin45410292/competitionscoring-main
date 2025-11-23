import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/token_util.dart';
import 'package:competition/util/http.dart'; // 导入你的HTTP请求封装

// 材料数据模型（对应后端返回格式）
class MaterialItem {
  final String eventName;
  final String eventOrganizer;
  final String materialUrl;
  final String materialStatus;

  MaterialItem({
    required this.eventName,
    required this.eventOrganizer,
    required this.materialUrl,
    required this.materialStatus,
  });

  // 从JSON解析模型
  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      eventName: json['event_name'] ?? '未知赛事',
      eventOrganizer: json['event_organizer'] ?? '未知举办单位',
      materialUrl: json['material_url'] ?? '',
      materialStatus: json['material_status'] ?? '未知状态',
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<MaterialItem> _materialList = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    // 页面初始化时加载材料列表
    _fetchMaterialList();
  }

  // 从后端获取学生上传的材料列表
  Future<void> _fetchMaterialList() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // 1. 获取本地存储的UserId
      String? userId = await TokenUtil.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception("未获取到userid");
      }

      // 2. 构造请求参数（根据上图示意，假设需要userId作为查询参数）
      Map<String, dynamic> queryParams = {
        'user_id': userId,
        // 可根据实际需求添加其他参数，如分页参数
        'page_num': 1,
        'page_size': 10,
      };

      // 3. 发送GET请求（使用封装的http_util中的get方法）
      Response response = await get(
        '/query/materials/stu', // 接口路径（会拼接baseUrl）
        queryParameters: queryParams,
      );

      // 4. 解析响应数据
      if (response.data['base']['code'] == 10000) {
        // 成功获取数据
        List<dynamic> items = response.data['data']['items'] ?? [];
        setState(() {
          _materialList = items.map((item) => MaterialItem.fromJson(item)).toList();
        });
      } else {
        // 后端返回业务错误
        throw Exception("获取材料失败：${response.data['base']['msg'] ?? '未知错误'}");
      }
    } catch (e) {
      // 捕获网络错误或业务错误
      setState(() {
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
      print("获取材料列表异常：$e");
    } finally {
      // 无论成功失败，都结束加载状态
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 根据状态获取对应的颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case '已审核':
        return Colors.green;
      case '待评审':
        return Colors.orange;
      case '驳回':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 重构：上传记录项（展示后端返回的材料信息）
  Widget _buildMaterialRecordItem(MaterialItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 赛事名称
          Text(
            item.eventName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          // 举办单位
          Text(
            '举办单位：${item.eventOrganizer}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          // 状态标签 + 查看详情按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 状态标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.materialStatus),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  item.materialStatus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // 查看详情按钮（点击跳转材料链接）
              GestureDetector(
                onTap: () {
                  // 点击查看详情：可使用url_launcher打开链接
                  // 需先在pubspec.yaml添加依赖：url_launcher: ^6.2.2
                  // 示例代码：
                  // if (item.materialUrl.isNotEmpty) {
                  //   launchUrl(Uri.parse(item.materialUrl));
                  // }
                  if (item.materialUrl.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('材料链接：${item.materialUrl}')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('暂无材料链接')),
                    );
                  }
                },
                child: Text(
                  '查看详情',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 加载状态组件
  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 10),
            Text('正在加载材料列表...'),
          ],
        ),
      ),
    );
  }

  // 错误状态组件
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 10),
            Text(
              _errorMsg ?? '加载失败',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _fetchMaterialList(), // 重新加载
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  // 空数据组件
  Widget _buildEmptyWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.file_download_off, color: Colors.grey, size: 40),
            SizedBox(height: 10),
            Text(
              '暂无上传材料记录',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          '材料上传',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 上传区域（保持原有样式）
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '点击此处自动或手动上传奖项',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '支持PDF、DOC、JPG、PNG格式，单个文件不超过50MB',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              '最近上传记录',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),

            // 材料列表展示区域
            if (_isLoading)
              _buildLoadingWidget()
            else if (_errorMsg != null)
              _buildErrorWidget()
            else if (_materialList.isEmpty)
                _buildEmptyWidget()
              else
                ..._materialList.map((item) => _buildMaterialRecordItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  // 保留原有未使用的方法（如需使用可自行启用）
  @Deprecated('已替换为_buildMaterialRecordItem，根据后端数据动态构建')
  Widget _buildRecordItem({
    required String name,
    required String status,
    required Color statusColor,
    required String actionText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            actionText,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 保留原有未使用的方法
  Widget _buildUploadingItem({
    required String name,
    required double progress,
    required String status,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: iconColor,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(status, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  // 保留原有未使用的方法
  Widget _buildCompletedItem({
    required String name,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 15)),
              Text(
                status,
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
