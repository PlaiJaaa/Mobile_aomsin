// Model ประกาศจากผู้ดูแลหอ (GET /announcements)
class AnnouncementData {
  final String id; // id ที่ json-server สร้างให้
  final String title;
  final String content;
  final bool isImportant; // เป็นประกาศสำคัญหรือไม่
  final DateTime createdAt; // วันที่ลงประกาศ

  // Constructor
  AnnouncementData({
    required this.id,
    required this.title,
    required this.content,
    required this.isImportant,
    required this.createdAt,
  });

  // แปลง JSON เป็น Object
  AnnouncementData.fromJson(Map<String, dynamic> json)
    : id = json['id'].toString(),
      title = json['title'] ?? '',
      content = json['content'] ?? '',
      isImportant = json['isImportant'] ?? false,
      createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

  // แปลง Object เป็น JSON Map สำหรับส่งไปกับ POST (ไม่ใส่ id)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'isImportant': isImportant,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
