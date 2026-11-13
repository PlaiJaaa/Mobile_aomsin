import 'dart:convert';

import '../constant/api_config.dart';
import '../model/announcement_data.dart';
import 'api_client.dart';

// จัดการข้อมูลประกาศ (REST API: /announcements)
class AnnouncementService {
  // GET /announcements : ประกาศทั้งหมด เรียงประกาศใหม่สุดขึ้นก่อน
  Future<List<AnnouncementData>> getAllAnnouncements() async {
    try {
      var response = await client
          .get(Uri.parse('$baseUrl/announcements'))
          .timeout(requestTimeout);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        List<AnnouncementData> announcements = jsonList
            .map((json) => AnnouncementData.fromJson(json))
            .toList();
        announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return announcements;
      } else {
        throw ApiException('โหลดประกาศไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ประกาศล่าสุดตามจำนวนที่ต้องการ (ใช้ในหน้าหลักผู้เช่า)
  Future<List<AnnouncementData>> getLatestAnnouncements(int count) async {
    List<AnnouncementData> announcements = await getAllAnnouncements();
    return announcements.take(count).toList();
  }

  // POST /announcements : ผู้ดูแลลงประกาศใหม่
  Future<void> createAnnouncement(AnnouncementData announcement) async {
    try {
      var response = await client
          .post(
            Uri.parse('$baseUrl/announcements'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(announcement.toJson()),
          )
          .timeout(requestTimeout);
      if (response.statusCode != 201) {
        throw ApiException('ลงประกาศไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }

  // DELETE /announcements/{id} : ผู้ดูแลลบประกาศ
  Future<void> deleteAnnouncement(String id) async {
    try {
      var response = await client
          .delete(Uri.parse('$baseUrl/announcements/$id'))
          .timeout(requestTimeout);
      if (response.statusCode != 200) {
        throw ApiException('ลบประกาศไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }
}
