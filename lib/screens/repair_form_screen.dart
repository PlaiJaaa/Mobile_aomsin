import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../model/repair_data.dart';
import '../model/user_data.dart';
import '../service/repair_service.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/primary_button.dart';

// ฟอร์มแจ้งซ่อมของผู้เช่า: หมวดหมู่ (Dropdown) ความเร่งด่วน (Radio)
// รายละเอียด (TextFormField) และอนุญาตให้ช่างเข้าห้อง (Switch)
class RepairFormScreen extends StatefulWidget {
  final UserData user; // ผู้เช่าที่กำลังแจ้งซ่อม

  const RepairFormScreen({super.key, required this.user});

  @override
  State<RepairFormScreen> createState() => _RepairFormScreenState();
}

class _RepairFormScreenState extends State<RepairFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _detailController = TextEditingController();
  final RepairService repairService = RepairService();

  String? _selectedCategory; // หมวดหมู่ที่เลือก
  String? _urgency = 'ปกติ'; // ความเร่งด่วน
  bool _allowEnter = false; // อนุญาตให้ช่างเข้าห้องตอนไม่อยู่
  bool _isSaving = false;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> submitRepair() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // สร้าง Object จากค่าที่กรอกในฟอร์ม (id เว้นว่าง เพราะ json-server จะสร้างให้)
    RepairData repair = RepairData(
      id: '',
      room: widget.user.room,
      tenantName: widget.user.name,
      category: _selectedCategory!,
      urgency: _urgency!,
      detail: _detailController.text.trim(),
      allowEnter: _allowEnter,
      status: repairPending,
      createdAt: DateTime.now(),
    );

    try {
      await repairService.createRepair(repair);
      if (!mounted) return;
      showSuccessSnackBar(context, 'ส่งเรื่องแจ้งซ่อมเรียบร้อย');
      // กลับไปหน้ารายการแจ้งซ่อม พร้อมส่ง true ให้หน้ารายการโหลดใหม่
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('แจ้งซ่อมใหม่')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'ห้อง ${widget.user.room} · ${widget.user.name}',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            // ---------- หมวดหมู่ ----------
            DropdownButtonFormField(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'หมวดหมู่ปัญหา',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              value: _selectedCategory,
              items: repairCategories
                  .map(
                    (String item) =>
                        DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (String? value) {
                if (value == null) {
                  return 'กรุณาเลือกหมวดหมู่ปัญหา';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ---------- ความเร่งด่วน ----------
            const Text(
              'ความเร่งด่วน',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: repairUrgencies.map((String item) {
                  return RadioListTile(
                    value: item,
                    title: Text(item),
                    secondary: Icon(
                      Icons.flag_rounded,
                      color: urgencyColor(item),
                    ),
                    groupValue: _urgency,
                    onChanged: (String? value) {
                      setState(() {
                        _urgency = value;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // ---------- รายละเอียด ----------
            TextFormField(
              controller: _detailController,
              maxLines: 4,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'รายละเอียดปัญหา',
                hintText: 'เช่น แอร์ไม่เย็น มีน้ำหยด',
                alignLabelWithHint: true,
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกรายละเอียดปัญหา';
                }
                if (value.trim().length < 10) {
                  return 'กรุณาอธิบายอย่างน้อย 10 ตัวอักษร';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // ---------- อนุญาตให้ช่างเข้าห้อง ----------
            Card(
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                title: const Text('อนุญาตให้ช่างเข้าห้องได้'),
                subtitle: const Text('กรณีที่ฉันไม่อยู่ห้องในเวลาซ่อม'),
                value: _allowEnter,
                onChanged: (bool value) {
                  setState(() {
                    _allowEnter = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'ส่งเรื่องแจ้งซ่อม',
              icon: Icons.send_rounded,
              isLoading: _isSaving,
              onPressed: submitRepair,
            ),
          ],
        ),
      ),
    );
  }
}
