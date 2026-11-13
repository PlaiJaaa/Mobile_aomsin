import '../constant/app_constant.dart';

// Model รายการแจ้งซ่อม (GET /repairs)
class RepairData {
  final String id; // id ที่ json-server สร้างให้
  final String room;
  final String tenantName; // ชื่อผู้แจ้ง
  final String category; // หมวดหมู่ เช่น ไฟฟ้า ประปา
  final String urgency; // ความเร่งด่วน: ปกติ / ด่วน / ด่วนมาก
  final String detail; // รายละเอียดปัญหา
  final bool allowEnter; // อนุญาตให้ช่างเข้าห้องตอนไม่อยู่หรือไม่
  final String status; // pending / in_progress / done
  final DateTime createdAt; // วันที่แจ้ง

  // Constructor
  RepairData({
    required this.id,
    required this.room,
    required this.tenantName,
    required this.category,
    required this.urgency,
    required this.detail,
    required this.allowEnter,
    required this.status,
    required this.createdAt,
  });

  // แปลง JSON เป็น Object
  RepairData.fromJson(Map<String, dynamic> json)
    : id = json['id'].toString(),
      room = json['room'] ?? '',
      tenantName = json['tenantName'] ?? '',
      category = json['category'] ?? 'อื่น ๆ',
      urgency = json['urgency'] ?? 'ปกติ',
      detail = json['detail'] ?? '',
      allowEnter = json['allowEnter'] ?? false,
      status = json['status'] ?? repairPending,
      createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

  // แปลง Object เป็น JSON Map สำหรับส่งไปกับ POST (ไม่ใส่ id)
  Map<String, dynamic> toJson() {
    return {
      'room': room,
      'tenantName': tenantName,
      'category': category,
      'urgency': urgency,
      'detail': detail,
      'allowEnter': allowEnter,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
