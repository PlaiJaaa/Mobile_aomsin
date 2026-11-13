import 'dart:convert';

import '../constant/api_config.dart';
import '../model/repair_data.dart';
import 'api_client.dart';

// จัดการข้อมูลแจ้งซ่อม (REST API: /repairs)
class RepairService {
  // GET /repairs : งานซ่อมทั้งหมด (ฝั่งผู้ดูแล)
  Future<List<RepairData>> getAllRepairs() async {
    return fetchRepairs('$baseUrl/repairs');
  }

  // GET /repairs?room=A101 : งานซ่อมของห้องที่ระบุ (ฝั่งผู้เช่า)
  Future<List<RepairData>> getRepairsByRoom(String room) async {
    return fetchRepairs('$baseUrl/repairs?room=$room');
  }

  // เรียก GET แล้วแปลง JSON เป็น List ของ RepairData เรียงรายการที่แจ้งล่าสุดขึ้นก่อน
  Future<List<RepairData>> fetchRepairs(String url) async {
    try {
      var response = await client.get(Uri.parse(url)).timeout(requestTimeout);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        List<RepairData> repairs = jsonList
            .map((json) => RepairData.fromJson(json))
            .toList();
        repairs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return repairs;
      } else {
        throw ApiException('โหลดงานซ่อมไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }

  // POST /repairs : ผู้เช่าแจ้งซ่อมใหม่
  Future<void> createRepair(RepairData repair) async {
    try {
      var response = await client
          .post(
            Uri.parse('$baseUrl/repairs'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(repair.toJson()),
          )
          .timeout(requestTimeout);
      if (response.statusCode != 201) {
        throw ApiException(
          'ส่งเรื่องแจ้งซ่อมไม่สำเร็จ (${response.statusCode})',
        );
      }
    } catch (e) {
      throw toApiException(e);
    }
  }

  // PATCH /repairs/{id} : ผู้ดูแลเปลี่ยนสถานะงานซ่อม
  Future<void> updateStatus(String id, String status) async {
    try {
      var response = await client
          .patch(
            Uri.parse('$baseUrl/repairs/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'status': status}),
          )
          .timeout(requestTimeout);
      if (response.statusCode != 200) {
        throw ApiException('เปลี่ยนสถานะไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }
}
