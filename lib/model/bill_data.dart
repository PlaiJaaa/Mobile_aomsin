import '../constant/app_constant.dart';

// Model บิลค่าเช่า/ค่าน้ำ/ค่าไฟ (GET /bills)
class BillData {
  final String id; // id ที่ json-server สร้างให้
  final String room;
  final int month; // เดือน 1-12
  final int year; // ปี พ.ศ.
  final double rent; // ค่าเช่า
  final double water; // ค่าน้ำ
  final double electric; // ค่าไฟ
  final String status; // unpaid / pending / paid
  final String paymentRef; // เลขอ้างอิงการโอนที่ผู้เช่าแจ้ง
  final DateTime createdAt; // วันที่ออกบิล

  // Constructor
  BillData({
    required this.id,
    required this.room,
    required this.month,
    required this.year,
    required this.rent,
    required this.water,
    required this.electric,
    required this.status,
    required this.paymentRef,
    required this.createdAt,
  });

  // แปลง JSON เป็น Object
  // ตัวเลขใช้ num แล้วค่อยแปลง เพราะ JSON อาจส่งมาเป็น int หรือ double
  // วันที่เก็บเป็นข้อความ ISO เช่น "2026-11-01T09:00:00.000" แล้วแปลงด้วย DateTime.tryParse
  BillData.fromJson(Map<String, dynamic> json)
    : id = json['id'].toString(),
      room = json['room'] ?? '',
      month = (json['month'] as num? ?? 1).toInt(),
      year = (json['year'] as num? ?? 0).toInt(),
      rent = (json['rent'] as num? ?? 0).toDouble(),
      water = (json['water'] as num? ?? 0).toDouble(),
      electric = (json['electric'] as num? ?? 0).toDouble(),
      status = json['status'] ?? billUnpaid,
      paymentRef = json['paymentRef'] ?? '',
      createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

  // แปลง Object เป็น JSON Map สำหรับส่งไปกับ POST
  // ไม่ใส่ id เพราะ json-server จะสร้าง id ให้เอง
  Map<String, dynamic> toJson() {
    return {
      'room': room,
      'month': month,
      'year': year,
      'rent': rent,
      'water': water,
      'electric': electric,
      'status': status,
      'paymentRef': paymentRef,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ยอดรวมของบิล
  double get total => rent + water + electric;

  // ข้อความรอบบิล เช่น "พฤศจิกายน 2569"
  String get monthText {
    if (month < 1 || month > 12) return 'ไม่ระบุเดือน';
    return '${thaiMonths[month - 1]} $year';
  }
}
