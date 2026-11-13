import 'package:flutter/material.dart';

// แสดง AlertDialog ถามยืนยันก่อนทำรายการสำคัญ (ลบ / เปลี่ยนสถานะ / ออกจากระบบ)
// คืนค่า true เมื่อผู้ใช้กดยืนยัน
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'ยืนยัน',
}) async {
  String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  // ถ้ากดนอกกล่องเพื่อปิด result จะเป็น null = ไม่ยืนยัน
  return result == 'OK';
}
