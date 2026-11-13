import 'dart:convert';

import '../constant/api_config.dart';
import '../constant/app_constant.dart';
import '../model/bill_data.dart';
import 'api_client.dart';

// จัดการข้อมูลบิล (REST API: /bills)
class BillService {
  // GET /bills : บิลทั้งหมด (ฝั่งผู้ดูแล) เรียงบิลที่ออกล่าสุดขึ้นก่อน
  Future<List<BillData>> getAllBills() async {
    List<BillData> bills = await fetchBills('$baseUrl/bills');
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }

  // GET /bills?room=A101 : บิลของห้องที่ระบุ (ฝั่งผู้เช่า) เรียงรอบบิลใหม่สุดขึ้นก่อน
  Future<List<BillData>> getBillsByRoom(String room) async {
    List<BillData> bills = await fetchBills('$baseUrl/bills?room=$room');
    bills.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });
    return bills;
  }

  // เรียก GET แล้วแปลง JSON เป็น List ของ BillData
  Future<List<BillData>> fetchBills(String url) async {
    try {
      var response = await client.get(Uri.parse(url)).timeout(requestTimeout);
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => BillData.fromJson(json)).toList();
      } else {
        throw ApiException('โหลดบิลไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ตรวจว่าห้องนี้มีบิลของเดือน/ปีนี้อยู่แล้วหรือยัง (กันออกบิลซ้ำ)
  Future<bool> isBillExists(String room, int month, int year) async {
    List<BillData> bills = await fetchBills('$baseUrl/bills?room=$room');
    for (BillData bill in bills) {
      if (bill.month == month && bill.year == year) {
        return true;
      }
    }
    return false;
  }

  // POST /bills : ผู้ดูแลออกบิลใหม่ (server ตอบ 201 Created)
  Future<void> createBill(BillData bill) async {
    try {
      var response = await client
          .post(
            Uri.parse('$baseUrl/bills'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(bill.toJson()),
          )
          .timeout(requestTimeout);
      if (response.statusCode != 201) {
        throw ApiException('ออกบิลไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }

  // PATCH /bills/{id} : แก้เฉพาะบางช่องของบิล
  Future<void> updateBill(String id, Map<String, dynamic> data) async {
    try {
      var response = await client
          .patch(
            Uri.parse('$baseUrl/bills/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(requestTimeout);
      if (response.statusCode != 200) {
        throw ApiException('บันทึกบิลไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }

  // ผู้เช่าแจ้งชำระเงินด้วยเลขอ้างอิง -> สถานะเป็นรอตรวจสอบ
  Future<void> submitPayment(String id, String paymentRef) async {
    await updateBill(id, {'status': billPending, 'paymentRef': paymentRef});
  }

  // ผู้ดูแลยืนยันว่าได้รับเงินแล้ว
  Future<void> confirmPayment(String id) async {
    await updateBill(id, {'status': billPaid});
  }

  // ผู้ดูแลไม่พบยอดโอน -> กลับไปเป็นค้างชำระให้ผู้เช่าแจ้งใหม่
  Future<void> rejectPayment(String id) async {
    await updateBill(id, {'status': billUnpaid, 'paymentRef': ''});
  }

  // DELETE /bills/{id} : ผู้ดูแลลบบิลที่ออกผิด
  Future<void> deleteBill(String id) async {
    try {
      var response = await client
          .delete(Uri.parse('$baseUrl/bills/$id'))
          .timeout(requestTimeout);
      if (response.statusCode != 200) {
        throw ApiException('ลบบิลไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw toApiException(e);
    }
  }
}
