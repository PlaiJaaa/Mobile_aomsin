import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../constant/app_format.dart';
import '../model/repair_data.dart';
import 'icon_box.dart';
import 'repair_progress.dart';
import 'status_chip.dart';

// การ์ดแสดงงานซ่อม 1 รายการ ใช้ทั้งฝั่งผู้เช่าและผู้ดูแล
class RepairCard extends StatelessWidget {
  final RepairData repair;
  final bool showRoom; // ฝั่งผู้ดูแลแสดงเลขห้องและชื่อผู้แจ้ง
  final Widget? action; // ปุ่มเปลี่ยนสถานะ (ฝั่งผู้ดูแล)

  const RepairCard({
    super.key,
    required this.repair,
    this.showRoom = false,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBox(
                  icon: categoryIcon(repair.category),
                  color: repairStatusColor(repair.status),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repair.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        showRoom
                            ? 'ห้อง ${repair.room} · ${repair.tenantName}'
                            : 'แจ้งเมื่อ ${formatDateTime(repair.createdAt)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(
                  text: repair.urgency,
                  color: urgencyColor(repair.urgency),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(repair.detail, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            // ผู้เช่าอนุญาตให้ช่างเข้าห้องตอนไม่อยู่หรือไม่
            Row(
              children: [
                Icon(
                  repair.allowEnter
                      ? Icons.key_rounded
                      : Icons.event_available_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    repair.allowEnter
                        ? 'ช่างเข้าห้องได้แม้ผู้เช่าไม่อยู่'
                        : 'ต้องนัดเวลากับผู้เช่าก่อนเข้าห้อง',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (showRoom) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'แจ้งเมื่อ ${formatDateTime(repair.createdAt)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            RepairProgress(status: repair.status),
            if (action != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
