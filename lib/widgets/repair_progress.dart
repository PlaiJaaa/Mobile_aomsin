import 'package:flutter/material.dart';

import '../constant/app_constant.dart';

// แถบความคืบหน้างานซ่อม 3 ขั้น: รอดำเนินการ -> กำลังซ่อม -> ซ่อมเสร็จแล้ว
// ใช้ AnimatedContainer ให้สีของแถบค่อย ๆ เปลี่ยนเมื่อสถานะเปลี่ยน
class RepairProgress extends StatelessWidget {
  final String status;

  const RepairProgress({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: buildStep(context, 0, 'รอดำเนินการ')),
        const SizedBox(width: 6),
        Expanded(child: buildStep(context, 1, 'กำลังซ่อม')),
        const SizedBox(width: 6),
        Expanded(child: buildStep(context, 2, 'เสร็จแล้ว')),
      ],
    );
  }

  // วาด 1 ขั้น: ขั้นที่ผ่านมาแล้ว (index <= ขั้นปัจจุบัน) จะมีสี
  Widget buildStep(BuildContext context, int index, String label) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final int currentStep = repairStatusStep(status);
    final bool isReached = index <= currentStep;
    final Color activeColor = isDark
        ? Color.lerp(repairStatusColor(status), Colors.white, 0.35)!
        : repairStatusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: 6,
          decoration: BoxDecoration(
            color: isReached
                ? activeColor
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: index == currentStep
                ? FontWeight.w600
                : FontWeight.normal,
            color: isReached ? activeColor : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
