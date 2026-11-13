import 'package:flutter/material.dart';

import '../model/announcement_data.dart';
import '../service/announcement_service.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/primary_button.dart';

// ฟอร์มลงประกาศของผู้ดูแล: หัวข้อ เนื้อหา และติ๊กว่าเป็นประกาศสำคัญ (Checkbox)
class AnnouncementFormScreen extends StatefulWidget {
  const AnnouncementFormScreen({super.key});

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final AnnouncementService announcementService = AnnouncementService();

  bool _isImportant = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> submitAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    AnnouncementData announcement = AnnouncementData(
      id: '',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      isImportant: _isImportant,
      createdAt: DateTime.now(),
    );

    try {
      await announcementService.createAnnouncement(announcement);
      if (!mounted) return;
      showSuccessSnackBar(context, 'ลงประกาศเรียบร้อย');
      // กลับไปหน้ารายการประกาศ พร้อมส่ง true ให้หน้ารายการโหลดใหม่
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
    return Scaffold(
      appBar: AppBar(title: const Text('ลงประกาศใหม่')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            TextFormField(
              controller: _titleController,
              maxLength: 60,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'หัวข้อประกาศ',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกหัวข้อประกาศ';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              maxLines: 6,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'เนื้อหาประกาศ',
                alignLabelWithHint: true,
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกเนื้อหาประกาศ';
                }
                if (value.trim().length < 10) {
                  return 'เนื้อหาต้องมีอย่างน้อย 10 ตัวอักษร';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: CheckboxListTile(
                title: const Text('เป็นประกาศสำคัญ'),
                subtitle: const Text('จะแสดงป้ายสีแดงให้ผู้เช่าเห็นชัดเจน'),
                value: _isImportant,
                onChanged: (bool? value) {
                  setState(() {
                    _isImportant = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'ลงประกาศ',
              icon: Icons.campaign_rounded,
              isLoading: _isSaving,
              onPressed: submitAnnouncement,
            ),
          ],
        ),
      ),
    );
  }
}
