import 'dart:convert';

import '../constant/api_config.dart';
import '../constant/app_constant.dart';
import '../model/user_data.dart';
import 'api_client.dart';

// จัดการข้อมูลผู้ใช้ (REST API: /users)
//
// หมายเหตุ: แอปนี้ดึงข้อมูลผู้ใช้รวมรหัสผ่านมาจาก server แล้วเทียบในแอป
// และรหัสผ่านเก็บเป็นข้อความธรรมดาใน db.json
// เหมาะกับงานสาธิตในรายวิชาเท่านั้น ระบบจริงต้องให้ server เป็นคนตรวจรหัสผ่าน และเข้ารหัสรหัสผ่านก่อนเก็บ
class UserService {
  // GET /users?username=xxx แล้วเทียบรหัสผ่าน
  // ถูกต้องคืนข้อมูลผู้ใช้ ไม่ถูกต้องคืน null
  Future<UserData?> login(String username, String password) async {
    try {
      var response = await client
          .get(
            Uri.parse(
              '$baseUrl/users',
            ).replace(queryParameters: {'username': username}),
          )
          .timeout(requestTimeout);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        for (var json in jsonList) {
          UserData user = UserData.fromJson(json);
          if (user.password == password) {
            return user;
          }
        }
        return null;
      } else {
        throw ApiException('เข้าสู่ระบบไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }

  // GET /users?role=tenant ดึงเลขห้องของผู้เช่าทั้งหมด ใช้เป็นตัวเลือกตอนผู้ดูแลออกบิล
  Future<List<String>> getTenantRooms() async {
    try {
      var response = await client
          .get(Uri.parse('$baseUrl/users?role=$roleTenant'))
          .timeout(requestTimeout);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        List<String> rooms = [];
        for (var json in jsonList) {
          UserData user = UserData.fromJson(json);
          if (!rooms.contains(user.room)) {
            rooms.add(user.room);
          }
        }
        rooms.sort();
        return rooms;
      } else {
        throw ApiException('โหลดรายชื่อห้องไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }
}
