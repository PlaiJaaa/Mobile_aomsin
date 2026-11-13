import 'package:flutter/material.dart';

import '../constant/color.dart';

// โลโก้แอป (กล่องไล่สี + ไอคอนตึก) ใช้ในหน้า Splash และหน้าเข้าสู่ระบบ
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14B8A6), primaryDarkColor],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.apartment_rounded,
        color: Colors.white,
        size: size * 0.55,
      ),
    );
  }
}
