import 'package:flutter/material.dart';

// ห่อ widget สถานะ (ว่าง / error) ด้วย ListView
// เพราะ RefreshIndicator ต้องมีรายการที่เลื่อนได้ จึงจะดึงลงเพื่อโหลดใหม่ได้
class ScrollMessage extends StatelessWidget {
  final Widget child;

  const ScrollMessage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // ให้ดึงลงได้แม้เนื้อหาจะสั้นกว่าหน้าจอ
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 80, bottom: 80),
      children: [child],
    );
  }
}
