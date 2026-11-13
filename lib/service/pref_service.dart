import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_data.dart';

// เก็บค่าลงเครื่องด้วย shared_preferences
// ใช้จำ 2 อย่าง: ธีมที่เลือก และผู้ใช้ที่ล็อกอินค้างไว้
class PrefService {
  // ---------- ธีม ----------
  Future<void> saveDarkMode(bool isDark) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<bool> getDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }

  // ---------- ผู้ใช้ที่ล็อกอิน ----------
  // เก็บเฉพาะข้อมูลที่ใช้แสดงผล ไม่เก็บรหัสผ่านลงเครื่อง
  Future<void> saveLoginUser(UserData user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('name', user.name);
    await prefs.setString('role', user.role);
    await prefs.setString('room', user.room);
    await prefs.setString('phone', user.phone);
  }

  // อ่านผู้ใช้ที่จำไว้ ถ้าไม่เคยล็อกอินค้างไว้คืน null
  Future<UserData?> getLoginUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      return null;
    }
    return UserData(
      id: userId,
      username: prefs.getString('username') ?? '',
      password: '',
      name: prefs.getString('name') ?? '',
      role: prefs.getString('role') ?? 'tenant',
      room: prefs.getString('room') ?? '-',
      phone: prefs.getString('phone') ?? '',
    );
  }

  // ลบผู้ใช้ที่จำไว้ (ตอนออกจากระบบ)
  Future<void> clearLoginUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('role');
    await prefs.remove('room');
    await prefs.remove('phone');
  }
}
