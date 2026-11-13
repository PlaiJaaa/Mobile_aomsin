import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../model/repair_data.dart';
import '../service/repair_service.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/repair_card.dart';
import '../widgets/scroll_message.dart';

// เมนูงานซ่อมของผู้ดูแล: ดูงานซ่อมทุกห้อง และเปลี่ยนสถานะทีละขั้น
// รอดำเนินการ -> กำลังซ่อม -> ซ่อมเสร็จแล้ว
class AdminRepairScreen extends StatefulWidget {
  const AdminRepairScreen({super.key});

  @override
  State<AdminRepairScreen> createState() => _AdminRepairScreenState();
}

class _AdminRepairScreenState extends State<AdminRepairScreen> {
  final RepairService repairService = RepairService();

  List<RepairData> repairs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadRepairs();
  }

  // GET /repairs แล้วเก็บผลไว้ใน state
  Future<void> loadRepairs() async {
    try {
      List<RepairData> result = await repairService.getAllRepairs();
      if (!mounted) return;
      setState(() {
        repairs = result;
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
    loadRepairs();
  }

  // เปลี่ยนสถานะงานซ่อม (ถามยืนยันก่อน)
  Future<void> changeStatus(RepairData repair, String newStatus) async {
    bool isConfirm = await showConfirmDialog(
      context,
      title: 'เปลี่ยนสถานะงานซ่อม',
      message:
          'ห้อง ${repair.room} · ${repair.category}\n'
          'เปลี่ยนสถานะเป็น "${repairStatusText(newStatus)}" ใช่หรือไม่',
    );
    if (!isConfirm) return;

    try {
      await repairService.updateStatus(repair.id, newStatus);
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        'อัปเดตงานซ่อมห้อง ${repair.room} เป็น "${repairStatusText(newStatus)}" แล้ว',
      );
      loadRepairs(); // โหลดรายการใหม่หลังเปลี่ยนสถานะ
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการงานซ่อม')),
      body: RefreshIndicator(onRefresh: loadRepairs, child: buildBody()),
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
    if (repairs.isEmpty) {
      return const ScrollMessage(
        child: EmptyView(
          icon: Icons.build_outlined,
          title: 'ยังไม่มีงานซ่อม',
          message: 'เมื่อผู้เช่าแจ้งซ่อมเข้ามา ดึงหน้าจอลงเพื่อดูรายการล่าสุด',
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
      itemCount: repairs.length,
      itemBuilder: (context, index) {
        final RepairData repair = repairs[index];
        return RepairCard(
          key: ValueKey(repair.id),
          repair: repair,
          showRoom: true,
          action: buildAction(repair),
        );
      },
    );
  }

  // ปุ่มเลื่อนสถานะไปขั้นถัดไป
  Widget? buildAction(RepairData repair) {
    if (repair.status == repairPending) {
      return Align(
        alignment: Alignment.centerRight,
        child: FilledButton.tonalIcon(
          onPressed: () => changeStatus(repair, repairInProgress),
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: const Text('รับงาน เริ่มซ่อม'),
        ),
      );
    }
    if (repair.status == repairInProgress) {
      return Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: () => changeStatus(repair, repairDone),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('ปิดงาน ซ่อมเสร็จแล้ว'),
        ),
      );
    }
    return null; // ซ่อมเสร็จแล้ว ไม่มีปุ่ม
  }
}
