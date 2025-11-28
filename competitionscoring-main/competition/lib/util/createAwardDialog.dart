//管理员端 新建认定奖项
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // 引入Dio（封装工具类依赖）
import 'package:competition/util/http.dart'; // 导入封装的HTTP工具类

class CreateAwardDialog extends StatefulWidget {
  const CreateAwardDialog({super.key});

  @override
  _CreateAwardDialogState createState() => _CreateAwardDialogState();
}

class _CreateAwardDialogState extends State<CreateAwardDialog> {
  // 输入框控制器
  final TextEditingController _competitionNameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _competitionTimeController = TextEditingController();
  final TextEditingController _recognitionBasisController = TextEditingController();
  final TextEditingController _relatedMajorsController = TextEditingController();

  // 下拉框选中变量
  String selectedApplyMajor = '软件工程';
  String selectedSchool = '计算机与大数据学院';
  String selectedGrade = '国家级';
  String fileName = '';

  // 加载状态
  bool _isLoading = false;

  // 可选择项
  final List<String> applyMajors = [
    '计算机科学与技术', '软件工程', '人工智能', '网络空间安全',
    '数据科学与大数据技术', '信息安全', '电气工程及其自动化', '自动化',
    '智能电网信息工程', '机器人工程', '测控技术与仪器', '机械设计制造及其自动化',
    '机械电子工程', '车辆工程', '智能制造工程', '工业设计',
    '过程装备与控制工程', '土木工程', '给排水科学与工程', '建筑环境与能源应用工程', '城市地下空间工程',
    '道路桥梁与渡河工程', '智能建造', '化学', '应用化学', '化学工程与工艺', '制药工程', '能源化学工程',
    '材料化学', '材料科学与工程', '高分子材料与工程', '无机非金属材料工程', '金属材料工程', '复合材料与工程',
    '环境工程', '环境科学', '安全工程', '环保设备工程', '金融学', '国际经济与贸易', '会计学', '工商管理',
    '市场营销', '财务管理', '人力资源管理', '物流管理', '信息管理与信息系统', '电子商务', '经济学', '财政学',
    '金融工程', '英语', '日语', '德语', '翻译', '商务英语'
  ];

  final List<String> schools = [
    '全部', '计算机与大数据学院', '电子与信息工程学院', '机械工程学院',
    '土木建筑工程学院', '经济管理学院', '外国语学院', '理学院',
    '人文社会科学学院', '医学院', '艺术学院', '法学院', '环境科学与工程学院'
  ];

  final List<String> grades = ['国家级', '省级', '校级', '国际级'];

  @override
  void dispose() {
    _competitionNameController.dispose();
    _unitController.dispose();
    _competitionTimeController.dispose();
    _recognitionBasisController.dispose();
    _relatedMajorsController.dispose();
    super.dispose();
  }

  // 提交表单到后端（使用封装的post方法）
  Future<void> _submitForm() async {
    // 获取表单数据
    String competitionName = _competitionNameController.text.trim();
    String unit = _unitController.text.trim();
    String competitionTime = _competitionTimeController.text.trim();
    String recognitionBasis = _recognitionBasisController.text.trim();
    String relatedMajors = _relatedMajorsController.text.trim();

    // 输入验证
    if (competitionName.isEmpty || unit.isEmpty || competitionTime.isEmpty ||
        recognitionBasis.isEmpty || relatedMajors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有必填项')),
      );
      return;
    }

    // 构建请求参数（与封装工具类的JSON格式兼容）
    final Map<String, dynamic> requestData = {
      "college": selectedSchool,
      "event_name": competitionName,
      "organizer": unit,
      "event_time": competitionTime,
      "related_majors": relatedMajors,
      "applicable_majors": selectedApplyMajor,
      "recognition_basis": recognitionBasis,
      "recognized_level": selectedGrade,
    };

    try {
      setState(() => _isLoading = true);

      // 调用封装的post方法（无需手动设置请求头和JSON编码）
      Response response = await post(
        '/admin/reward/upload', // 仅传接口路径（baseUrl在http.dart中已配置）
        data: requestData, // 直接传Map，封装工具类会自动转为JSON
      );

      // 解析响应（封装工具类已处理响应格式）
      final Map<String, dynamic> responseData = response.data;

      // 检查后端返回状态
      if (responseData['base']['code'] == 10000) {
        // 成功处理
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交成功！奖励ID: ${responseData['data']['recognize_reward_id']}')),
        );
        Navigator.pop(context, responseData['data']); // 返回结果给调用页面
      } else {
        // 后端返回错误
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: ${responseData['base']['msg']}')),
        );
      }
    } catch (e) {
      // 捕获封装工具类抛出的异常（已格式化错误信息）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    setState(() {
      _competitionNameController.clear();
      _unitController.clear();
      _competitionTimeController.clear();
      _recognitionBasisController.clear();
      _relatedMajorsController.clear();
      selectedApplyMajor = '软件工程';
      selectedSchool = '计算机与大数据学院';
      selectedGrade = '国家级';
      fileName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '新建认定奖项',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 14),

                // 输入框组
                _buildInputField(
                  label: '竞赛名称：',
                  controller: _competitionNameController,
                  hintText: '请输入竞赛名称',
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  label: '主办单位：',
                  controller: _unitController,
                  hintText: '请输入主办单位',
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  label: '竞赛时间：',
                  controller: _competitionTimeController,
                  hintText: '请输入竞赛时间（如：每年7月至8月）',
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  label: '官方认定依据文件或标准：',
                  controller: _recognitionBasisController,
                  hintText: '请输入官方认定依据文件或标准',
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  label: '赛事涉及的专业范围：',
                  controller: _relatedMajorsController,
                  hintText: '请输入赛事涉及的专业范围（如：不限）',
                ),
                const SizedBox(height: 16),

                // 下拉框组
                _buildDropdownField(
                  label: '实际申请认定的专业：',
                  value: selectedApplyMajor,
                  items: applyMajors,
                  onChanged: (value) => setState(() => selectedApplyMajor = value!),
                ),
                const SizedBox(height: 16),

                _buildDropdownField(
                  label: '学院：',
                  value: selectedSchool,
                  items: schools,
                  onChanged: (value) => setState(() => selectedSchool = value!),
                ),
                const SizedBox(height: 16),

                _buildDropdownField(
                  label: '认定级别：',
                  value: selectedGrade,
                  items: grades,
                  onChanged: (value) => setState(() => selectedGrade = value!),
                ),
                const SizedBox(height: 16),

                // 文件上传
                Row(
                  children: [
                    const Text("通过文件上传："),
                    ElevatedButton.icon(
                      onPressed: () {
                        // 此处可添加文件上传逻辑（如需上传文件，可使用封装的postFormData方法）
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('上传文件'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(fileName.isEmpty ? '未选择文件' : fileName),
                  ],
                ),
                const SizedBox(height: 20),

                // 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _resetForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                      ),
                      child: const Text('重置', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text('确定', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 输入框构建方法
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  // 下拉框组件
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      menuMaxHeight: 300,
    );
  }
}
