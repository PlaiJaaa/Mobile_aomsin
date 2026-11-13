import 'package:intl/intl.dart';

// ฟังก์ชันจัดรูปแบบข้อความ ใช้ package intl

// จำนวนเงิน เช่น 4260.5 -> ฿4,260.50
String formatMoney(double amount) {
  return '฿${NumberFormat('#,##0.00').format(amount)}';
}

// วันที่แบบไทย เช่น 13 พ.ย. 2569 14:30 น. (ปี พ.ศ. = ค.ศ. + 543)
String formatDateTime(DateTime date) {
  String dayMonth = DateFormat('d MMM', 'th').format(date);
  String time = DateFormat('HH:mm').format(date);
  return '$dayMonth ${date.year + 543} $time น.';
}
