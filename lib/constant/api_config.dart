import 'package:flutter/foundation.dart';

// ตั้งค่าการเชื่อมต่อ REST API (json-server ในโฟลเดอร์ server/)
// ถ้าต้องเปลี่ยน port หรือเครื่อง server ให้แก้ที่ไฟล์นี้จุดเดียว

const int serverPort = 3000;

// เลือกที่อยู่ server ให้อัตโนมัติตามเครื่องที่รันแอป
// - Android Emulator มองเครื่องคอมพิวเตอร์ของเราเป็น 10.0.2.2
//   (localhost ใน emulator หมายถึงตัว emulator เอง จึงเรียกไม่ถึง server)
// - Chrome / Windows ใช้ localhost ได้ตามปกติ
String get baseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:$serverPort';
  }
  return 'http://localhost:$serverPort';
}

// เวลารอสูงสุดของแต่ละคำขอ ถ้าเกินนี้ถือว่าเชื่อมต่อ server ไม่สำเร็จ
const Duration requestTimeout = Duration(seconds: 10);
