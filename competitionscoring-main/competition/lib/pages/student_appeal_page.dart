// 辅导员端 查看学生申诉
import 'package:flutter/material.dart';
import 'appeal_detail_dialog.dart';
import 'package:competition/util/http.dart';

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
  bool _isDetailLoading = false;

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

  // 格式化时间戳
  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty || timestamp == '0') return '未知时间';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '时间格式错误';
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

      final response = await get('/admin/query/appeal/stu', queryParameters: queryParams);

      if (response.data['base']['code'] == 10000) {
        final items = response.data['data']['items'] as List<dynamic>;
        setState(() {
          appeals = items.map((item) => _convertApiDataToAppeal(item)).toList();
        });
      } else {
        final errorMsg = response.data['base']['msg'] ?? '请求失败';
        throw Exception(errorMsg);
      }
    } catch (e) {
      setState(() {
        errorMessage = '加载失败: ${e.toString()}';
        appeals = [];
      });
    } finally {
      setState(() => isLoading = false);
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

    // 处理附件路径显示
    String formatAttachmentPath(String? path) {
      if (path == null || path.isEmpty) return '无附件';
      final fileName = path.split('/').last.split('\\').last;
      return fileName;
    }

    return {
      'title': apiData['appeal_type'] ?? '分级异议',
      'date': formatDate(int.tryParse(apiData['created_at']?.toString() ?? '0') ?? 0),
      'user_id': apiData['user_id'] ?? '未知学号',
      'event_id': apiData['event_id'] ?? '',
      'result_id': apiData['result_id'] ?? '',
      'appeal_id': apiData['appeal_id'] ?? '',
      'event_name': apiData['event_name'] ?? '未知赛事',
      'award_level': apiData['award_level'] ?? '无',
      'appeal_reason': apiData['appeal_reason'] ?? '无申诉原因',
      'final_score': apiData['final_score'] ?? '0.0',
      'attachment_path': formatAttachmentPath(apiData['attachment_path']),
      'status': uiStatus,
      'color': statusColor,
      'original_data': apiData,
    };
  }

  // 查看申诉详情（已处理的申诉）
  Future<void> _viewAppealDetail(String appealId) async {
    try {
      setState(() => _isDetailLoading = true);

      // 调用查询详情接口
      final response = await get('/query/appeal', queryParameters: {'appeal_id': appealId});

      if (response.data['base']['code'] == 10000) {
        final detailData = response.data['data'];
        _showDetailViewDialog(detailData);
      } else {
        throw Exception(response.data['base']['msg'] ?? '获取详情失败');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取详情失败: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isDetailLoading = false);
    }
  }

  // 显示已处理申诉的详情弹窗 - 优化滚动体验
  void _showDetailViewDialog(Map<String, dynamic> detailData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white, // 白底
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        elevation: 10,
        // 限制弹窗左右边距，大屏幕更美观
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        // 弹窗主体使用Column拆分固定区域和滚动区域
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 固定标题栏（始终可见）
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${detailData['appeal_type']}详情',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Colors.grey.shade100,
                  ),
                ],
              ),
            ),

            // 2. 可滚动内容区（核心优化部分）
            ConstrainedBox(
              // 限制最大高度为屏幕的70%，避免超出可视范围
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                minHeight: 120, // 最小高度，防止内容过少时弹窗过矮
              ),
              child: SingleChildScrollView(
                // 内边距与标题栏、按钮区呼应
                padding: const EdgeInsets.all(24),
                // 滚动行为优化：支持惯性滚动，边缘回弹
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 详情信息展示 - 保持原有样式
                    _buildDetailRow('申诉ID', detailData['appeal_id'] ?? '未知'),
                    _buildDetailRow('申诉人学号', detailData['user_id'] ?? '未知'),
                    _buildDetailRow('赛事名称', detailData['event_name'] ?? '未知'),
                    _buildDetailRow('赛事级别', detailData['event_level'] ?? '未知'),
                    _buildDetailRow('获奖等级', detailData['award_level'] ?? '未知'),
                    _buildDetailRow('最终得分', detailData['final_score']?.toString() ?? '0.0'),
                    _buildDetailRow('申诉类型', detailData['appeal_type'] ?? '未知'),
                    _buildDetailRow('申诉原因', detailData['appeal_reason'] ?? '无'),
                    _buildDetailRow('申诉时间', _formatTimestamp(detailData['created_at']?.toString() ?? '0')),
                    _buildDetailRow('处理状态', _getUiStatus(detailData['status'] ?? '')),
                    _buildDetailRow('处理人', detailData['handleBy'] ?? '未知'),
                    _buildDetailRow('处理时间', _formatTimestamp(detailData['handleTime']?.toString() ?? '0')),
                    _buildDetailRow('处理结果', detailData['handleResult'] ?? '无'),
                  ],
                ),
              ),
            ),

            // 3. 固定底部按钮区（始终可见）
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // 去除阴影，更简洁
                    elevation: 0,
                  ),
                  child: const Text(
                    '关闭',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建详情页信息行 - 优化UI
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF333333),
              height: 1.3, // 增加行高，提升可读性
            ),
            softWrap: true,
          ),
          // 分隔线
          if (label != '处理结果') // 最后一项不加分隔线
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(height: 1, color: Colors.grey.shade50),
            ),
        ],
      ),
    );
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
                // _buildDropdown('学年', selectedYear, yearOptions, (v) => setState(() => selectedYear = v!)),
                // const SizedBox(width: 10),
                // _buildDropdown('赛事级别', selectedLevel, levelOptions, (v) => setState(() => selectedLevel = v!)),
                // const SizedBox(width: 10),
                _buildDropdown('状态', selectedStatus, statusOptions, (v) => setState(() {
                  selectedStatus = v!;
                  _loadAppeals();
                })),
              ],
            ),
            const SizedBox(height: 16),

            // 加载状态显示
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (errorMessage.isNotEmpty)
              Expanded(
                child: Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red))),
              )
            else if (appeals.isEmpty)
                const Expanded(child: Center(child: Text('暂无申诉数据')))
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
                            // 申诉类型和状态行
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item['color'],
                                    borderRadius: BorderRadius.circular(6),
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
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 详细信息展示
                            _buildInfoRow('申诉人学号', item['user_id']),
                            _buildInfoRow('赛事名称', item['event_name']),
                            _buildInfoRow('获奖等级', item['award_level']),
                            _buildInfoRow('最终得分', item['final_score'].toString()),
                            _buildInfoRow('申诉时间', item['date']),
                            _buildInfoRow('附件', item['attachment_path'],
                                isAttachment: true,
                                attachmentPath: item['original_data']['attachment_path']),

                            const SizedBox(height: 12),

                            // 申诉原因
                            const Text(
                              '申诉原因：',
                              style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['appeal_reason'],
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                                softWrap: true,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 操作按钮区
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 待审核状态显示"处理申诉"按钮
                                  if (item['status'] == '待审核')
                                    GestureDetector(
                                      onTap: () => _showDetailDialog(item, index),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[600],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '处理申诉',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // 已处理状态显示"查看详情"按钮
                                  if (item['status'] != '待审核')
                                    GestureDetector(
                                      onTap: () => _viewAppealDetail(item['appeal_id']),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[600],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: _isDetailLoading
                                            ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                            : const Text(
                                          '查看详情',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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

  // 构建信息行（通用组件）
  Widget _buildInfoRow(String label, String value, {bool isAttachment = false, String? attachmentPath}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label：',
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: isAttachment
                ? GestureDetector(
              onTap: () {
                if (attachmentPath != null && attachmentPath.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('附件路径：$attachmentPath')),
                  );
                }
              },
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: attachmentPath != null && attachmentPath.isNotEmpty
                      ? Colors.blue[600]
                      : Colors.black87,
                  decoration: attachmentPath != null && attachmentPath.isNotEmpty
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
                : Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

  // 显示待处理申诉的详情弹窗
  void _showDetailDialog(Map<String, dynamic> item, int index) {
    String handledResult = '';

    showDialog(
      context: context,
      builder: (context) => AppealDetailDialog(
        item: item,
        eventId: item['event_id'],
        resultId: item['result_id'],
        appealId: item['appeal_id'],
        onApprove: () {
          if (handledResult.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请输入处理结果'), backgroundColor: Colors.orange),
            );
            return;
          }
          _handleAppealReview(item['appeal_id'], true, handledResult);
        },
        onReject: () {
          if (handledResult.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请输入处理结果'), backgroundColor: Colors.orange),
            );
            return;
          }
          _handleAppealReview(item['appeal_id'], false, handledResult);
        },
        onResultChanged: (value) {
          handledResult = value;
        },
      ),
    );
  }

  // 处理申诉审核
  Future<void> _handleAppealReview(String appealId, bool isApprove, String handledResult) async {
    try {
      final status = isApprove ? 'approved' : 'rejected';
      final response = await post('/appeal/status', data: {
        'appeal_id': appealId,
        'status': status,
        'handled_result': handledResult,
      });

      if (response.data['base']['code'] == 10000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isApprove ? '审核通过操作成功' : '审核驳回操作成功'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          _loadAppeals();
        }
      } else {
        throw Exception(response.data['base']['msg'] ?? '操作失败');
      }
    } catch (e) {
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
