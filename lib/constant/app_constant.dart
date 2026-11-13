import 'package:flutter/material.dart';

import 'color.dart';

// ค่าคงที่ที่ใช้ร่วมกันทั้งแอป

const String appName = 'หอพักอุ่นใจ';

// บัญชีรับโอนค่าเช่า (ข้อมูลสมมติ แสดงในหน้าแจ้งชำระ)
const String dormBankName = 'ธนาคารตัวอย่าง';
const String dormBankAccount = '123-4-56789-0';
const String dormBankOwner = 'หอพักอุ่นใจ';

// ---------- บทบาทผู้ใช้ ----------
const String roleTenant = 'tenant'; // ผู้เช่า
const String roleAdmin = 'admin'; // ผู้ดูแลหอ

// ---------- สถานะบิล ----------
const String billUnpaid = 'unpaid'; // ค้างชำระ
const String billPending = 'pending'; // แจ้งชำระแล้ว รอผู้ดูแลตรวจสอบ
const String billPaid = 'paid'; // ชำระแล้ว

// แปลงสถานะบิลเป็นข้อความภาษาไทย
String billStatusText(String status) {
  if (status == billPaid) return 'ชำระแล้ว';
  if (status == billPending) return 'รอตรวจสอบ';
  return 'ค้างชำระ';
}

// สีของสถานะบิล
Color billStatusColor(String status) {
  if (status == billPaid) return successColor;
  if (status == billPending) return warningColor;
  return dangerColor;
}

// ---------- สถานะงานซ่อม ----------
const String repairPending = 'pending'; // รอดำเนินการ
const String repairInProgress = 'in_progress'; // กำลังซ่อม
const String repairDone = 'done'; // ซ่อมเสร็จแล้ว

String repairStatusText(String status) {
  if (status == repairDone) return 'ซ่อมเสร็จแล้ว';
  if (status == repairInProgress) return 'กำลังซ่อม';
  return 'รอดำเนินการ';
}

Color repairStatusColor(String status) {
  if (status == repairDone) return successColor;
  if (status == repairInProgress) return infoColor;
  return warningColor;
}

// ลำดับขั้นของงานซ่อม (0, 1, 2) ใช้วาดแถบความคืบหน้า
int repairStatusStep(String status) {
  if (status == repairDone) return 2;
  if (status == repairInProgress) return 1;
  return 0;
}

// ---------- ตัวเลือกในฟอร์มแจ้งซ่อม ----------
const List<String> repairCategories = [
  'ไฟฟ้า',
  'ประปา',
  'เครื่องปรับอากาศ',
  'เฟอร์นิเจอร์',
  'อินเทอร์เน็ต',
  'อื่น ๆ',
];

const List<String> repairUrgencies = ['ปกติ', 'ด่วน', 'ด่วนมาก'];

Color urgencyColor(String urgency) {
  if (urgency == 'ด่วนมาก') return dangerColor;
  if (urgency == 'ด่วน') return warningColor;
  return successColor;
}

// ไอคอนของแต่ละหมวดงานซ่อม
IconData categoryIcon(String category) {
  if (category == 'ไฟฟ้า') return Icons.bolt_rounded;
  if (category == 'ประปา') return Icons.water_drop_rounded;
  if (category == 'เครื่องปรับอากาศ') return Icons.ac_unit_rounded;
  if (category == 'เฟอร์นิเจอร์') return Icons.chair_rounded;
  if (category == 'อินเทอร์เน็ต') return Icons.wifi_rounded;
  return Icons.build_rounded;
}

// ---------- ชื่อเดือนภาษาไทย ----------
const List<String> thaiMonths = [
  'มกราคม',
  'กุมภาพันธ์',
  'มีนาคม',
  'เมษายน',
  'พฤษภาคม',
  'มิถุนายน',
  'กรกฎาคม',
  'สิงหาคม',
  'กันยายน',
  'ตุลาคม',
  'พฤศจิกายน',
  'ธันวาคม',
];
