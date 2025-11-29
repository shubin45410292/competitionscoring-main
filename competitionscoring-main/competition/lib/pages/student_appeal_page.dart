import 'package:flutter/material.dart';
import 'appeal_detail_dialog.dart';
import 'package:competition/util/http.dart';
import 'package:competition/util/token_util.dart';

class StudentAppealPage extends StatefulWidget {
  const StudentAppealPage({super.key});

  @override
  State<StudentAppealPage> createState() => _StudentAppealPageState();
}

class _StudentAppealPageState extends State<StudentAppealPage> {
  String selectedYear = '2024-2025';
  String selectedLevel = '全部';
  String selectedStatus = '待审核';

  final List<String> yearOptions = ['2024-2025', '2023-2024', '2022-2023'];
  final List<String> levelOptions = ['全部', '校级', '省级', '国家级'];
  final List<String> statusOptions = ['待审核', '审核通过', '审核驳回'];

  List<Map<String, dynamic>> appeals = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAppeals();
  }

  // 状态映射：前端状态 -> 后端状态
  String _getApiStatus(String uiStatus) {
    switch (uiStatus) {
      case '待审核':
        return 'pending';
      case '审核通过':
        return 'approved';
      case '审核驳回':
        return 'rejected';
      default:
        return 'pending';
    }
  }

  // 状态映射：后端状态 -> 前端状态
  String _getUiStatus(String apiStatus) {
    switch (apiStatus) {
      case 'pending':
        return '待审核';
      case 'approved':
        return '审核通过';
      case 'rejected':
        return '审核驳回';
      default:
        return '待审核';
    }
  }

  // 从后端加载申诉数据
  Future<void> _loadAppeals() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      Map<String, dynamic> queryParams = {};
      if (selectedStatus != '全部') {
        queryParams['status'] = _getApiStatus(selectedStatus);
      }

      print('发送请求，参数: $queryParams');

      final response = await get('/admin/query/appeal/stu', queryParameters: queryParams);

      print('收到响应: ${response.data}');

      if (response.data['base']['code'] == 10000) {
        final items = response.data['data']['items'] as List<dynamic>;
        print('获取到 ${items.length} 条申诉数据');

        setState(() {
          appeals = items.map((item) {
            return _convertApiDataToAppeal(item);
          }).toList();
        });
      } else {
        final errorMsg = response.data['base']['msg'] ?? '请求失败';
        print('API返回错误: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('加载申诉数据异常: $e');
      setState(() {
        errorMessage = '加载失败: ${e.toString()}';
        appeals = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 将API数据转换为前端使用的格式
  Map<String, dynamic> _convertApiDataToAppeal(dynamic apiData) {
    Color statusColor = Colors.orange;
    String uiStatus = _getUiStatus(apiData['status'] ?? 'pending');

    switch (uiStatus) {
      case '审核通过':
        statusColor = const Color.fromARGB(255, 138, 200, 113);
        break;
      case '审核驳回':
        statusColor = const Color.fromARGB(255, 232, 93, 80);
        break;
      case '待审核':
      default:
        statusColor = Colors.orange;
        break;
    }

    String formatDate(int timestamp) {
      if (timestamp == 0) return '未知时间';
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    String generateInfo(dynamic data) {
      return '${data['appeal_type'] ?? "分级异议"} - 申诉ID: ${data['appeal_id']}';
    }

    String generateStudentInfo(dynamic data) {
      return '学号: ${data['user_id']}';
    }

    return {
      'title': apiData['appeal_type'] ?? '分级异议',
      'date': formatDate(int.tryParse(apiData['created_at']?.toString() ?? '0') ?? 0),
      'info': generateInfo(apiData),
      'content': apiData['appeal_reason'] ?? '无申诉原因',
      'student': generateStudentInfo(apiData),
      'status': uiStatus,
      'color': statusColor,
      'original_data': apiData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: const Text(
          '学生申诉',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 顶部筛选行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown('学年', selectedYear, yearOptions, (v) {
                  setState(() => selectedYear = v!);
                }),
                const SizedBox(width: 10),
                _buildDropdown('赛事级别', selectedLevel, levelOptions, (v) {
                  setState(() => selectedLevel = v!);
                }),
                const SizedBox(width: 10),
                _buildDropdown('状态', selectedStatus, statusOptions, (v) {
                  setState(() {
                    selectedStatus = v!;
                    _loadAppeals();
                  });
                }),
              ],
            ),
            const SizedBox(height: 16),

            // 加载状态显示
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (appeals.isEmpty)
                const Expanded(
                  child: Center(child: Text('暂无申诉数据')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: appeals.length,
                    itemBuilder: (context, index) {
                      final item = appeals[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 8,
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
                                Text(
                                  item['title'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text('申诉时间：${item['date']}',
                                style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            Text('识别信息：${item['info']}',
                                style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            Text('申诉内容：${item['content']}',
                                style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            Text('申诉人：${item['student']}',
                                style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (item['status'] == '待审核') {
                                        _showDetailDialog(item, index);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: item['color'],
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: item['color']),
                                      ),
                                      child: Text(
                                        item['status'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // 通用下拉菜单构建
  Widget _buildDropdown(String label, String value, List<String> options,
      ValueChanged<String?> onChanged) {
    return Expanded(
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            items: options
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ))
                .toList(),
          ),
        ),
      ),
    );
  }

  // 显示详情弹窗（修复：添加 onResultChanged 参数）
  void _showDetailDialog(Map<String, dynamic> item, int index) {
    String handledResult = ''; // 存储处理结果输入框的内容

    showDialog(
      context: context,
      builder: (context) => AppealDetailDialog(
        item: item,
        onApprove: () {
          // 审核通过前验证处理结果是否为空
          if (handledResult.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请输入处理结果'), backgroundColor: Colors.orange),
            );
            return;
          }
          // 调用审核接口并传递处理结果
          _handleAppealReview(item['original_data']['appeal_id'], true, handledResult);
        },
        onReject: () {
          // 审核驳回前验证处理结果是否为空
          if (handledResult.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请输入处理结果'), backgroundColor: Colors.orange),
            );
            return;
          }
          // 调用审核接口并传递处理结果
          _handleAppealReview(item['original_data']['appeal_id'], false, handledResult);
        },
        // 补充缺失的参数：接收输入框的内容
        onResultChanged: (value) {
          handledResult = value; // 实时更新处理结果
        },
      ),
    );
  }

  // 处理申诉审核（新增 handledResult 参数接收处理结果）
  Future<void> _handleAppealReview(String appealId, bool isApprove, String handledResult) async {
    try {
      // 构建请求参数（包含处理结果）
      final status = isApprove ? 'approved' : 'rejected';
      final response = await post('/appeal/status', data: {
        'appeal_id': appealId,
        'status': status,
        'handled_result': handledResult, // 传递处理结果到后端
      });

      if (response.data['base']['code'] == 10000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isApprove ? '审核通过操作成功' : '审核驳回操作成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // 关闭弹窗
          _loadAppeals(); // 刷新列表数据
        }
      } else {
        throw Exception(response.data['base']['msg'] ?? '操作失败');
      }
    } catch (e) {
      print('处理申诉失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
