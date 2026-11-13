// Model ผู้ใช้งาน (GET /users)
class UserData {
  final String id; // id ที่ json-server สร้างให้
  final String username;
  final String password;
  final String name;
  final String role; // 'tenant' = ผู้เช่า, 'admin' = ผู้ดูแล
  final String room; // เลขห้อง (ผู้ดูแลใช้ '-')
  final String phone;

  // Constructor
  UserData({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.room,
    required this.phone,
  });

  // แปลง JSON เป็น Object
  UserData.fromJson(Map<String, dynamic> json)
    : id = json['id'].toString(),
      username = json['username'] ?? '',
      password = json['password'] ?? '',
      name = json['name'] ?? '',
      role = json['role'] ?? 'tenant',
      room = json['room'] ?? '-',
      phone = json['phone'] ?? '';

  // แปลง Object เป็น JSON Map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'role': role,
      'room': room,
      'phone': phone,
    };
  }
}
