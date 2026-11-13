import 'package:flutter/material.dart';

import '../constant/app_format.dart';

// การ์ดสรุปยอดค้างชำระในหน้าหลักของผู้เช่า
// ใช้ AnimatedContainer: มียอดค้าง = โทนส้มแดง, ไม่มียอดค้าง = โทนเขียว
// เมื่อโหลดข้อมูลใหม่แล้วยอดเปลี่ยน สีจะค่อย ๆ เปลี่ยนตาม
class SummaryCard extends StatelessWidget {
  final double unpaidTotal; // ยอดรวมบิลที่ค้างชำระ
  final int unpaidCount; // จำนวนบิลที่ค้างชำระ
  final int pendingCount; // จำนวนบิลที่แจ้งชำระแล้วรอตรวจสอบ
  final VoidCallback onTap;

  const SummaryCard({
    super.key,
    required this.unpaidTotal,
    required this.unpaidCount,
    required this.pendingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = unpaidCount > 0;

    // ข้อความบรรทัดล่างสุด
    String message;
    if (hasDebt) {
      message = 'มี $unpaidCount บิลที่ยังไม่ได้ชำระ';
    } else if (pendingCount > 0) {
      message = 'แจ้งชำระแล้ว รอผู้ดูแลตรวจสอบ $pendingCount บิล';
    } else {
      message = 'ไม่มียอดค้างชำระ ขอบคุณที่ชำระตรงเวลา';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasDebt
              ? const [Color(0xFFEA580C), Color(0xFFBE123C)]
              : const [Color(0xFF14B8A6), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasDebt
                    ? Icons.account_balance_wallet_rounded
                    : Icons.verified_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'ยอดค้างชำระ',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // AnimatedSwitcher: ตัวเลขยอดเงินค่อย ๆ สลับเมื่อยอดเปลี่ยน
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              formatMoney(unpaidTotal),
              key: ValueKey(unpaidTotal),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: hasDebt
                    ? const Color(0xFFBE123C)
                    : const Color(0xFF0F766E),
              ),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: Text(hasDebt ? 'ดูบิลและแจ้งชำระ' : 'ดูบิลทั้งหมด'),
            ),
          ),
        ],
      ),
    );
  }
}
