import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../constant/app_format.dart';
import '../model/bill_data.dart';
import 'icon_box.dart';
import 'status_chip.dart';

// การ์ดแสดงบิล 1 ใบ ใช้ทั้งฝั่งผู้เช่าและผู้ดูแล
class BillCard extends StatelessWidget {
  final BillData bill;
  final bool showRoom; // ฝั่งผู้ดูแลแสดงเลขห้องเป็นหัวข้อ
  final VoidCallback? onTap;
  final Widget? action; // ปุ่มเพิ่มเติมด้านล่างการ์ด (ฝั่งผู้ดูแล)

  const BillCard({
    super.key,
    required this.bill,
    this.showRoom = false,
    this.onTap,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color statusColor = billStatusColor(bill.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBox(icon: Icons.receipt_long_rounded, color: statusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showRoom ? 'ห้อง ${bill.room}' : bill.monthText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          showRoom
                              ? 'รอบบิล ${bill.monthText}'
                              : 'ออกบิล ${formatDateTime(bill.createdAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatMoney(bill.total),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StatusChip(
                        text: billStatusText(bill.status),
                        color: statusColor,
                      ),
                    ],
                  ),
                ],
              ),
              // เลขอ้างอิงที่ผู้เช่าแจ้ง (แสดงให้ผู้ดูแลใช้ตรวจสอบ)
              if (showRoom && bill.paymentRef.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.tag_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'เลขอ้างอิง ${bill.paymentRef}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
