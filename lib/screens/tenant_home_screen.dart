import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../constant/color.dart';
import '../model/announcement_data.dart';
import '../model/bill_data.dart';
import '../model/user_data.dart';
import '../service/announcement_service.dart';
import '../service/bill_service.dart';
import '../widgets/announcement_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/icon_box.dart';
import '../widgets/loading_view.dart';
import '../widgets/scroll_message.dart';
import '../widgets/section_title.dart';
import '../widgets/summary_card.dart';

// หน้าหลักของผู้เช่า: ยอดค้างชำระ + ทางลัดแจ้งซ่อม + ประกาศล่าสุด
class TenantHomeScreen extends StatefulWidget {
  final UserData user;
  final void Function(int index) onChangeTab; // สั่งให้หน้าแม่เปลี่ยนเมนู

  const TenantHomeScreen({
    super.key,
    required this.user,
    required this.onChangeTab,
  });

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  final BillService billService = BillService();
  final AnnouncementService announcementService = AnnouncementService();

  List<BillData> bills = []; // บิลของห้องนี้
  List<AnnouncementData> announcements = []; // ประกาศล่าสุด
  bool isLoading = true; // กำลังโหลดข้อมูลครั้งแรก
  String? errorMessage; // ข้อความ error (null = ไม่มี error)

  @override
  void initState() {
    super.initState();
    loadData(); // โหลดข้อมูลทันทีที่เปิดหน้า
  }

  // GET บิลของห้อง และประกาศล่าสุด 3 รายการ
  Future<void> loadData() async {
    try {
      List<BillData> billResult = await billService.getBillsByRoom(
        widget.user.room,
      );
      List<AnnouncementData> announcementResult = await announcementService
          .getLatestAnnouncements(3);
      if (!mounted) return;
      setState(() {
        bills = billResult;
        announcements = announcementResult;
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

  // กดปุ่มลองใหม่ในหน้า error
  void retry() {
    setState(() {
      isLoading = true;
    });
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // ดึงหน้าจอลงเพื่อโหลดข้อมูลใหม่
        child: RefreshIndicator(onRefresh: loadData, child: buildBody()),
      ),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        buildHeader(context),
        const SizedBox(height: 20),
        buildBillSummary(),
        const SizedBox(height: 16),
        buildRepairShortcut(context),
        const SizedBox(height: 20),
        SectionTitle(
          title: 'ประกาศล่าสุด',
          actionText: 'ดูทั้งหมด',
          onAction: () => widget.onChangeTab(3),
        ),
        const SizedBox(height: 4),
        buildLatestAnnouncements(),
      ],
    );
  }

  // ส่วนหัว: คำทักทาย ชื่อ และเลขห้อง
  Widget buildHeader(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'สวัสดี',
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.meeting_room_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'ห้อง ${widget.user.room}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // การ์ดยอดค้างชำระ คำนวณจากบิลที่โหลดมา
  Widget buildBillSummary() {
    double unpaidTotal = 0;
    int unpaidCount = 0;
    int pendingCount = 0;
    for (BillData bill in bills) {
      if (bill.status == billUnpaid) {
        unpaidTotal = unpaidTotal + bill.total;
        unpaidCount++;
      } else if (bill.status == billPending) {
        pendingCount++;
      }
    }

    return SummaryCard(
      unpaidTotal: unpaidTotal,
      unpaidCount: unpaidCount,
      pendingCount: pendingCount,
      onTap: () => widget.onChangeTab(1),
    );
  }

  // ทางลัดไปเมนูแจ้งซ่อม
  Widget buildRepairShortcut(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => widget.onChangeTab(2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const IconBox(icon: Icons.build_rounded, color: secondaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'แจ้งซ่อม',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'แจ้งปัญหาในห้องพัก และติดตามสถานะการซ่อม',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  // ประกาศล่าสุด 3 รายการ
  Widget buildLatestAnnouncements() {
    if (announcements.isEmpty) {
      return const EmptyView(
        icon: Icons.campaign_outlined,
        title: 'ยังไม่มีประกาศ',
        message: 'เมื่อผู้ดูแลลงประกาศใหม่ จะแสดงที่นี่',
      );
    }

    return Column(
      children: announcements.map((AnnouncementData announcement) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AnnouncementCard(
            key: ValueKey(announcement.id),
            announcement: announcement,
          ),
        );
      }).toList(),
    );
  }
}
