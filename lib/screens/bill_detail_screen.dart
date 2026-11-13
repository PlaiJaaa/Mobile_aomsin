import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../constant/app_format.dart';
import '../constant/color.dart';
import '../model/bill_data.dart';
import '../service/bill_service.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/info_row.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_chip.dart';

// รายละเอียดบิลของผู้เช่า
// ถ้าบิลยังค้างชำระ จะมีฟอร์มกรอกเลขอ้างอิงการโอนเพื่อแจ้งชำระ
class BillDetailScreen extends StatefulWidget {
  final BillData bill; // บิลที่เลือกมาจากหน้ารายการ

  const BillDetailScreen({super.key, required this.bill});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _refController = TextEditingController();
  final BillService billService = BillService();
  bool _isSaving = false;

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  Future<void> submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String paymentRef = _refController.text.trim();

    // ถามยืนยันก่อนเปลี่ยนสถานะบิล
    bool isConfirm = await showConfirmDialog(
      context,
      title: 'ยืนยันการแจ้งชำระ',
      message:
          'แจ้งชำระบิล ${widget.bill.monthText} '
          'ยอด ${formatMoney(widget.bill.total)}\n'
          'เลขอ้างอิง $paymentRef',
      confirmText: 'แจ้งชำระ',
    );
    if (!isConfirm || !mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await billService.submitPayment(widget.bill.id, paymentRef);
      if (!mounted) return;
      showSuccessSnackBar(context, 'แจ้งชำระเรียบร้อย รอผู้ดูแลตรวจสอบ');
      // กลับไปหน้ารายการบิล พร้อมส่ง true บอกว่าข้อมูลเปลี่ยน ให้โหลดใหม่
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
    final BillData bill = widget.bill;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดบิล')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ---------- รายการค่าใช้จ่าย ----------
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bill.monthText,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ห้อง ${bill.room}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(
                        text: billStatusText(bill.status),
                        color: billStatusColor(bill.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  InfoRow(label: 'ค่าเช่าห้อง', value: formatMoney(bill.rent)),
                  InfoRow(label: 'ค่าน้ำ', value: formatMoney(bill.water)),
                  InfoRow(label: 'ค่าไฟ', value: formatMoney(bill.electric)),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  InfoRow(
                    label: 'ยอดรวม',
                    value: formatMoney(bill.total),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---------- ส่วนล่างเปลี่ยนตามสถานะบิล ----------
          if (bill.status == billUnpaid) buildPaymentForm(context),
          if (bill.status == billPending)
            buildNotice(
              icon: Icons.hourglass_top_rounded,
              color: warningColor,
              title: 'แจ้งชำระแล้ว รอผู้ดูแลตรวจสอบ',
              message: 'เลขอ้างอิง ${bill.paymentRef}',
            ),
          if (bill.status == billPaid)
            buildNotice(
              icon: Icons.check_circle_rounded,
              color: successColor,
              title: 'ชำระเรียบร้อยแล้ว',
              message: bill.paymentRef.isEmpty
                  ? 'ขอบคุณที่ชำระตรงเวลา'
                  : 'เลขอ้างอิง ${bill.paymentRef}',
            ),
        ],
      ),
    );
  }

  // ฟอร์มแจ้งชำระ (แสดงเฉพาะบิลที่ค้างชำระ)
  Widget buildPaymentForm(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'แจ้งชำระเงิน',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          // บัญชีสำหรับโอนเงิน
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'โอนเงินมาที่ $dormBankName',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Text(
                          dormBankAccount,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ชื่อบัญชี $dormBankOwner',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _refController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'เลขอ้างอิงการโอน',
              hintText: 'ดูได้จากสลิปโอนเงิน',
              prefixIcon: Icon(Icons.tag_rounded),
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'กรุณากรอกเลขอ้างอิงการโอน';
              }
              if (value.trim().length < 6) {
                return 'เลขอ้างอิงต้องมีอย่างน้อย 6 ตัวอักษร';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'แจ้งชำระเงิน',
            icon: Icons.send_rounded,
            isLoading: _isSaving,
            onPressed: submitPayment,
          ),
        ],
      ),
    );
  }

  // กล่องข้อความแจ้งสถานะ (รอตรวจสอบ / ชำระแล้ว)
  Widget buildNotice({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
