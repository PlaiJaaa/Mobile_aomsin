import 'package:flutter/material.dart';

// กล่องไอคอนมุมมนพื้นสีอ่อน ใช้นำหน้าการ์ดรายการต่าง ๆ
class IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const IconBox({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.25 : 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: isDark ? Color.lerp(color, Colors.white, 0.45) : color,
      ),
    );
  }
}
