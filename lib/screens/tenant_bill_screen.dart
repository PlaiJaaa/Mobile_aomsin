import 'package:flutter/material.dart';

import '../model/bill_data.dart';
import '../model/user_data.dart';
import '../service/bill_service.dart';
import '../widgets/bill_card.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/scroll_message.dart';
import 'bill_detail_screen.dart';

// เมนูบิลของผู้เช่า: แสดงบิลทั้งหมดของห้องตัวเอง แตะเพื่อดูรายละเอียด/แจ้งชำระ
class TenantBillScreen extends StatefulWidget {
  final UserData user;

  const TenantBillScreen({super.key, required this.user});

  @override
  State<TenantBillScreen> createState() => _TenantBillScreenState();
}

class _TenantBillScreenState extends State<TenantBillScreen> {
  final BillService billService = BillService();

  List<BillData> bills = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadBills();
  }

  // GET /bills?room=... แล้วเก็บผลไว้ใน state
  Future<void> loadBills() async {
    try {
      List<BillData> result = await billService.getBillsByRoom(
        widget.user.room,
      );
      if (!mounted) return;
      setState(() {
        bills = result;
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
    loadBills();
  }

  // เปิดหน้ารายละเอียดบิล ถ้ากลับมาพร้อมค่า true (แจ้งชำระสำเร็จ) ให้โหลดใหม่
  Future<void> openBill(BillData bill) async {
    bool? isChanged = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BillDetailScreen(bill: bill)),
    );
    if (isChanged == true) {
      loadBills();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('บิลของห้อง ${widget.user.room}')),
      body: RefreshIndicator(onRefresh: loadBills, child: buildBody()),
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
    if (bills.isEmpty) {
      return const ScrollMessage(
        child: EmptyView(
          icon: Icons.receipt_long_outlined,
          title: 'ยังไม่มีบิล',
          message: 'เมื่อผู้ดูแลออกบิลประจำเดือน จะแสดงที่นี่',
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final BillData bill = bills[index];
        return BillCard(
          key: ValueKey(bill.id),
          bill: bill,
          onTap: () => openBill(bill),
        );
      },
    );
  }
}
