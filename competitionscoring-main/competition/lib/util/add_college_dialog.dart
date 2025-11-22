// 组件_编辑学院/专业对话框(学院信息管理页面(管理员端))

import 'package:flutter/material.dart';

class AddCollegeDialog extends StatefulWidget {
  const AddCollegeDialog({super.key});

  @override
  State<AddCollegeDialog> createState() => _AddCollegeDialogState();
}

class _AddCollegeDialogState extends State<AddCollegeDialog> {
  int selectedTab = 0; // 0 = 学院，1 = 专业

  // ---- 学院模式数据 ----
  final TextEditingController _collegeNameController = TextEditingController();
  final List<String> allMajors = [
    '软件工程',
    '材料工程',
    '车辆工程',
    '航天与航空工程',
    '电子信息工程'
  ];
  final Set<String> selectedMajors = {'软件工程'};

  // ---- 专业模式数据 ----
  final TextEditingController _majorNameController = TextEditingController();
  String selectedCollege = '计算机与大数据';
  final List<String> collegeOptions = ['计算机与大数据', '外国语', '管理学院'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请选择需要新增的内容（学院/专业）',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),

            // 顶部切换按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton('学院', 0),
                _buildTabButton('专业', 1),
              ],
            ),

            const SizedBox(height: 20),

            // 切换显示不同表单
            if (selectedTab == 0)
              _buildCollegeEditForm()
            else
              _buildMajorEditForm(),

            const SizedBox(height: 20),

            // 底部按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _collegeNameController.clear();
                    _majorNameController.clear();
                    selectedMajors.clear();
                  },
                  child: const Text('重置'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: 这里写保存逻辑
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  ),
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 顶部 tab 切换按钮
  Widget _buildTabButton(String label, int index) {
    final bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue[600]!),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------------- 学院修改表单 ----------------
  Widget _buildCollegeEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _collegeNameController,
          decoration: const InputDecoration(
            labelText: '学院名称',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        _buildMultiSelectDropdown(),
      ],
    );
  }

  // 多选下拉框（复选）
  Widget _buildMultiSelectDropdown() {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<Set<String>>(
          context: context,
          builder: (context) {
            final tempSelected = Set<String>.from(selectedMajors);
            return AlertDialog(
              title: const Text('选择拥有专业'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: allMajors
                      .map((major) => CheckboxListTile(
                    value: tempSelected.contains(major),
                    title: Text(major),
                    onChanged: (checked) {
                      if (checked == true) {
                        tempSelected.add(major);
                      } else {
                        tempSelected.remove(major);
                      }
                      setState(() {}); // 即时刷新复选状态
                    },
                  ))
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, selectedMajors),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );

        if (result != null) {
          setState(() => selectedMajors
            ..clear()
            ..addAll(result));
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '拥有专业',
          border: OutlineInputBorder(),
        ),
        child: Text(
          selectedMajors.isEmpty
              ? '请选择'
              : selectedMajors.join('，'),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  // ---------------- 专业修改表单 ----------------
  Widget _buildMajorEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _majorNameController,
          decoration: const InputDecoration(
            labelText: '专业名称',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedCollege,
          decoration: const InputDecoration(
            labelText: '所属学院',
            border: OutlineInputBorder(),
          ),
          items: collegeOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => selectedCollege = v!),
        ),
      ],
    );
  }
}
