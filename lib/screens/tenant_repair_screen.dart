import 'package:flutter/material.dart';

import '../model/repair_data.dart';
import '../model/user_data.dart';
import '../service/repair_service.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/repair_card.dart';
import '../widgets/scroll_message.dart';
import 'repair_form_screen.dart';

// เมนูแจ้งซ่อมของผู้เช่า: ดูรายการที่เคยแจ้ง ติดตามสถานะ และแจ้งซ่อมใหม่
// ดึงหน้าจอลงเพื่อดูสถานะล่าสุดที่ผู้ดูแลอัปเดต
class TenantRepairScreen extends StatefulWidget {
  final UserData user;

  const TenantRepairScreen({super.key, required this.user});

  @override
  State<TenantRepairScreen> createState() => _TenantRepairScreenState();
}

class _TenantRepairScreenState extends State<TenantRepairScreen> {
  final RepairService repairService = RepairService();

  List<RepairData> repairs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadRepairs();
  }

  // GET /repairs?room=... แล้วเก็บผลไว้ใน state
  Future<void> loadRepairs() async {
    try {
      List<RepairData> result = await repairService.getRepairsByRoom(
        widget.user.room,
      );
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

  // เปิดฟอร์มแจ้งซ่อม ถ้าส่งเรื่องสำเร็จ (กลับมาพร้อม true) ให้โหลดรายการใหม่
  Future<void> openForm() async {
    bool? isAdded = await Navigator.push(
      context,
      MaterialPageRoute(
        // ส่งข้อมูลผู้เช่าไปหน้าฟอร์มผ่าน constructor
        builder: (context) => RepairFormScreen(user: widget.user),
      ),
    );
    if (isAdded == true) {
      loadRepairs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แจ้งซ่อม')),
      body: RefreshIndicator(onRefresh: loadRepairs, child: buildBody()),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'repairFab', // ตั้งชื่อไม่ให้ซ้ำกับปุ่มลอยของหน้าอื่น
        onPressed: openForm,
        icon: const Icon(Icons.add_rounded),
        label: const Text('แจ้งซ่อมใหม่'),
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
    if (repairs.isEmpty) {
      return const ScrollMessage(
        child: EmptyView(
          icon: Icons.build_outlined,
          title: 'ยังไม่มีรายการแจ้งซ่อม',
          message: 'พบปัญหาในห้องพัก กดปุ่ม "แจ้งซ่อมใหม่" ด้านล่างได้เลย',
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      // เว้นด้านล่างไว้ไม่ให้ปุ่มลอยบังรายการสุดท้าย
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
      itemCount: repairs.length,
      itemBuilder: (context, index) {
        final RepairData repair = repairs[index];
        return RepairCard(key: ValueKey(repair.id), repair: repair);
      },
    );
  }
}
