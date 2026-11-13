import 'package:flutter/material.dart';

// แถวข้อมูล ซ้ายเป็นหัวข้อ ขวาเป็นค่า (ใช้ในรายละเอียดบิล และโปรไฟล์)
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold; // ตัวหนา ใช้กับแถวยอดรวม

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 15,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: isBold
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: isBold ? 20 : 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isBold ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
