import 'package:flutter/material.dart';

import '../model/announcement_data.dart';
import '../service/announcement_service.dart';
import '../widgets/announcement_card.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/scroll_message.dart';
import 'announcement_form_screen.dart';

// เมนูประกาศ ใช้ร่วมกัน 2 บทบาท
// - ผู้เช่า (isAdmin = false): อ่านอย่างเดียว
// - ผู้ดูแล (isAdmin = true): ลงประกาศใหม่และลบประกาศได้
class AnnouncementScreen extends StatefulWidget {
  final bool isAdmin;

  const AnnouncementScreen({super.key, required this.isAdmin});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final AnnouncementService announcementService = AnnouncementService();

  List<AnnouncementData> announcements = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadAnnouncements();
  }

  // GET /announcements แล้วเก็บผลไว้ใน state
  Future<void> loadAnnouncements() async {
    try {
      List<AnnouncementData> result = await announcementService
          .getAllAnnouncements();
      if (!mounted) return;
      setState(() {
        announcements = result;
        errorMessage = null;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void retry() {
    setState(() {
      isLoading = true;
    });
    loadAnnouncements();
  }

  Future<void> deleteAnnouncement(AnnouncementData announcement) async {
    // ถามยืนยันก่อนลบ
    bool isConfirm = await showConfirmDialog(
      context,
      title: 'ลบประกาศ',
      message: 'ต้องการลบประกาศ "${announcement.title}" หรือไม่',
      confirmText: 'ลบ',
    );
    if (!isConfirm) return;

    try {
      await announcementService.deleteAnnouncement(announcement.id);
      if (!mounted) return;
      showSuccessSnackBar(context, 'ลบประกาศเรียบร้อย');
      loadAnnouncements(); // โหลดรายการใหม่หลังลบ
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
    }
  }

  // เปิดฟอร์มลงประกาศ ถ้าลงสำเร็จ (กลับมาพร้อม true) ให้โหลดรายการใหม่
  Future<void> openForm() async {
    bool? isAdded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnnouncementFormScreen()),
    );
    if (isAdded == true) {
      loadAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ประกาศจากหอพัก')),
      body: RefreshIndicator(onRefresh: loadAnnouncements, child: buildBody()),
      // ปุ่มลงประกาศ มีเฉพาะผู้ดูแล
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              heroTag:
                  'announcementFab', // ตั้งชื่อไม่ให้ซ้ำกับปุ่มลอยของหน้าอื่น
              onPressed: openForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('ลงประกาศ'),
            )
          : null,
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const LoadingView();
    }
    if (errorMessage != null) {
      return ScrollMessage(
        child: ErrorView(message: errorMessage!, onRetry: retry),
      );
    }
    if (announcements.isEmpty) {
      return ScrollMessage(
        child: EmptyView(
          icon: Icons.campaign_outlined,
          title: 'ยังไม่มีประกาศ',
          message: widget.isAdmin
              ? 'กดปุ่ม "ลงประกาศ" ด้านล่างเพื่อแจ้งข่าวถึงผู้เช่า'
              : 'เมื่อผู้ดูแลลงประกาศใหม่ จะแสดงที่นี่',
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 8, 20, widget.isAdmin ? 96 : 24),
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final AnnouncementData announcement = announcements[index];
        return AnnouncementCard(
          key: ValueKey(announcement.id),
          announcement: announcement,
          // ผู้เช่าไม่มีปุ่มลบ (ส่ง null)
          onDelete: widget.isAdmin
              ? () => deleteAnnouncement(announcement)
              : null,
        );
      },
    );
  }
}
