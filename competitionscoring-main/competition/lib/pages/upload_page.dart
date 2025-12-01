import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:competition/util/token_util.dart';
import 'package:competition/util/http.dart';
import 'package:competition/util/upload_file_dialog.dart';
import 'package:url_launcher/url_launcher.dart';  // 导入url_launcher
import 'package:url_launcher/url_launcher_string.dart';  // 导入字符串链接跳转工具

// 材料数据模型（保持不变）
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
    _fetchMaterialList();  // 初始加载数据
  }

  // 获取材料列表
  Future<void> _fetchMaterialList() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      String? userId = await TokenUtil.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception("未获取到userid");
      }

      Map<String, dynamic> queryParams = {
        'Id': userId,
        'page_num': 1,
        'page_size': 10,
      };

      Response response = await get(
        '/query/materials/stu',
        queryParameters: queryParams,
      );

      if (response.data['base']['code'] == 10000) {
        List<dynamic> items = response.data['data']['items'] ?? [];
        setState(() {
          _materialList = items.map((item) => MaterialItem.fromJson(item)).toList();
        });
      } else {
        throw Exception("获取材料失败：${response.data['base']['msg'] ?? '未知错误'}");
      }
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
      print("获取材料列表异常：$e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 状态颜色（保持不变）
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

  // 关键修改：完善查看详情的跳转逻辑
  Future<void> _openMaterialUrl(String url) async {
    if (!await canLaunchUrlString(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('链接无效，无法打开')),
      );
      return;
    }

    try {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开失败：${e.toString()}')),
      );
      print("打开材料链接异常：$e");
    }
  }

  // 材料记录项（修改查看详情的点击事件）
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
          Text(
            item.eventName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '举办单位：${item.eventOrganizer}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              GestureDetector(
                onTap: () => _openMaterialUrl(item.materialUrl), // 直接打开链接
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

  // 以下组件保持不变
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
              onPressed: () => _fetchMaterialList(),
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
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => UploadFileDialog(
                    // 上传文件后更新材料列表
                    onUploadSuccess: () {
                      print("上传成功，开始刷新材料列表...");
                      _fetchMaterialList();  // 刷新数据
                    },
                  ),
                );
              },
              child: Container(
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
            ),
            const SizedBox(height: 16),
            const Text(
              '最近上传记录',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),
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
}
