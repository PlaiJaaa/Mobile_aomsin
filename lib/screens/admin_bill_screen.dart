import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../constant/app_format.dart';
import '../constant/color.dart';
import '../model/bill_data.dart';
import '../service/bill_service.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/bill_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/scroll_message.dart';
import 'bill_form_screen.dart';

// เมนูบิลของผู้ดูแล: ดูบิลทุกห้อง กรองตามสถานะ ออกบิลใหม่
// ตรวจสอบ/ยืนยันการชำระ และลบบิลที่ออกผิด
class AdminBillScreen extends StatefulWidget {
  const AdminBillScreen({super.key});

  @override
  State<AdminBillScreen> createState() => _AdminBillScreenState();
}

class _AdminBillScreenState extends State<AdminBillScreen> {
  final BillService billService = BillService();

  List<BillData> allBills = []; // บิลทั้งหมดที่โหลดมาจาก server
  bool isLoading = true;
  String? errorMessage;

  String _filter = 'all'; // ตัวกรองสถานะ: all / unpaid / pending / paid

  @override
  void initState() {
    super.initState();
    loadBills();
  }

  // GET /bills แล้วเก็บผลไว้ใน state
  Future<void> loadBills() async {
    try {
      List<BillData> result = await billService.getAllBills();
      if (!mounted) return;
      setState(() {
        allBills = result;
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

  // เปิดฟอร์มออกบิล ถ้าออกบิลสำเร็จ (กลับมาพร้อม true) ให้โหลดรายการใหม่
  Future<void> openForm() async {
    bool? isAdded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BillFormScreen()),
    );
    if (isAdded == true) {
      loadBills();
    }
  }

  // ตรวจสอบการแจ้งชำระของผู้เช่า: ยืนยันรับเงิน หรือ ไม่พบยอดโอน
  Future<void> checkPayment(BillData bill) async {
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('ตรวจสอบการชำระ'),
        content: Text(
          'ห้อง ${bill.room} · ${bill.monthText}\n'
          'ยอด ${formatMoney(bill.total)}\n'
          'เลขอ้างอิง ${bill.paymentRef}\n\n'
          'ได้รับเงินโอนรายการนี้แล้วใช่หรือไม่',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Reject'),
            style: TextButton.styleFrom(foregroundColor: dangerColor),
            child: const Text('ไม่พบยอดโอน'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('ยืนยันรับชำระ'),
          ),
        ],
      ),
    );

    try {
      if (result == 'OK') {
        await billService.confirmPayment(bill.id);
        if (!mounted) return;
        showSuccessSnackBar(context, 'ยืนยันการชำระห้อง ${bill.room} แล้ว');
      } else if (result == 'Reject') {
        await billService.rejectPayment(bill.id);
        if (!mounted) return;
        showSuccessSnackBar(
          context,
          'ตีกลับบิลห้อง ${bill.room} เป็นค้างชำระแล้ว',
        );
      } else {
        return; // กดยกเลิก ไม่ต้องโหลดใหม่
      }
      loadBills(); // โหลดรายการใหม่หลังเปลี่ยนสถานะ
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
    }
  }

  Future<void> deleteBill(BillData bill) async {
    // ถามยืนยันก่อนลบ
    bool isConfirm = await showConfirmDialog(
      context,
      title: 'ลบบิล',
      message:
          'ต้องการลบบิลห้อง ${bill.room} รอบ ${bill.monthText} '
          'ยอด ${formatMoney(bill.total)} หรือไม่',
      confirmText: 'ลบ',
    );
    if (!isConfirm) return;

    try {
      await billService.deleteBill(bill.id);
      if (!mounted) return;
      showSuccessSnackBar(context, 'ลบบิลเรียบร้อย');
      loadBills(); // โหลดรายการใหม่หลังลบ
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('จัดการบิล')),
      body: RefreshIndicator(onRefresh: loadBills, child: buildBody()),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'billFab', // ตั้งชื่อไม่ให้ซ้ำกับปุ่มลอยของหน้าอื่น
        onPressed: openForm,
        icon: const Icon(Icons.add_rounded),
        label: const Text('ออกบิล'),
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
    if (allBills.isEmpty) {
      return const ScrollMessage(
        child: EmptyView(
          icon: Icons.receipt_long_outlined,
          title: 'ยังไม่มีบิลในระบบ',
          message: 'กดปุ่ม "ออกบิล" ด้านล่างเพื่อออกบิลให้ผู้เช่า',
        ),
      );
    }

    // กรองตามสถานะที่เลือก
    List<BillData> bills = allBills.where((bill) {
      return _filter == 'all' || bill.status == _filter;
    }).toList();

    return Column(
      children: [
        buildFilterBar(allBills),
        Expanded(
          child: bills.isEmpty
              ? const ScrollMessage(
                  child: EmptyView(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'ไม่มีบิลในสถานะนี้',
                    message: 'ลองเลือกตัวกรองสถานะอื่นด้านบน',
                  ),
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 12),
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final BillData bill = bills[index];
                    return BillCard(
                      key: ValueKey(bill.id),
                      bill: bill,
                      showRoom: true,
                      action: buildAction(bill),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // แถบตัวกรองสถานะ พร้อมจำนวนบิลของแต่ละสถานะ
  Widget buildFilterBar(List<BillData> allBills) {
    int countByStatus(String status) {
      return allBills.where((bill) => bill.status == status).length;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          buildFilterChip('all', 'ทั้งหมด (${allBills.length})'),
          buildFilterChip(
            billPending,
            'รอตรวจสอบ (${countByStatus(billPending)})',
          ),
          buildFilterChip(
            billUnpaid,
            'ค้างชำระ (${countByStatus(billUnpaid)})',
          ),
          buildFilterChip(billPaid, 'ชำระแล้ว (${countByStatus(billPaid)})'),
        ],
      ),
    );
  }

  Widget buildFilterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (bool selected) {
          setState(() {
            _filter = value;
          });
        },
      ),
    );
  }

  // ปุ่มด้านล่างการ์ด เปลี่ยนตามสถานะบิล
  Widget? buildAction(BillData bill) {
    if (bill.status == billPending) {
      return Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: () => checkPayment(bill),
          icon: const Icon(Icons.fact_check_outlined, size: 18),
          label: const Text('ตรวจสอบการชำระ'),
        ),
      );
    }
    if (bill.status == billUnpaid) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () => deleteBill(bill),
          style: TextButton.styleFrom(foregroundColor: dangerColor),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text('ลบบิล'),
        ),
      );
    }
    return null; // ชำระแล้ว ไม่มีปุ่ม
  }
}
