import 'package:dorm_app/constant/app_constant.dart';
import 'package:dorm_app/constant/app_format.dart';
import 'package:dorm_app/model/announcement_data.dart';
import 'package:dorm_app/model/bill_data.dart';
import 'package:dorm_app/model/repair_data.dart';
import 'package:dorm_app/model/user_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// ทดสอบ Model (fromJson / toJson) และฟังก์ชันจัดรูปแบบ
void main() {
  setUpAll(() async {
    await initializeDateFormatting('th');
  });

  group('BillData', () {
    test('fromJson แล้ว toJson ได้ค่าเดิม และคำนวณยอดรวมถูก', () {
      final BillData bill = BillData.fromJson({
        'id': 7,
        'room': 'A101',
        'month': 11,
        'year': 2569,
        'rent': 3500,
        'water': 120.5,
        'electric': 640,
        'status': 'pending',
        'paymentRef': 'TRX001',
        'createdAt': '2026-11-01T09:30:00.000',
      });

      expect(bill.id, '7'); // id ตัวเลขจาก json-server กลายเป็น String
      expect(bill.rent, 3500.0); // int ใน JSON ต้องกลายเป็น double
      expect(bill.total, 4260.5);
      expect(bill.monthText, 'พฤศจิกายน 2569');
      expect(bill.createdAt, DateTime(2026, 11, 1, 9, 30));

      final Map<String, dynamic> json = bill.toJson();
      expect(json['room'], 'A101');
      expect(json['status'], 'pending');
      expect(json['createdAt'], '2026-11-01T09:30:00.000');
      expect(json.containsKey('id'), false); // ให้ json-server สร้าง id เอง
    });

    test('ข้อมูลไม่ครบก็ไม่พัง ใช้ค่าเริ่มต้นแทน', () {
      final BillData bill = BillData.fromJson({'id': 'x'});
      expect(bill.room, '');
      expect(bill.total, 0);
      expect(bill.status, billUnpaid);
      expect(bill.monthText, 'มกราคม 0');
    });

    test('เดือนนอกช่วง 1-12 แสดงว่าไม่ระบุเดือน', () {
      final BillData bill = BillData.fromJson({
        'id': 1,
        'month': 13,
        'year': 2569,
      });
      expect(bill.monthText, 'ไม่ระบุเดือน');
    });
  });

  test('RepairData fromJson / toJson', () {
    final RepairData repair = RepairData.fromJson({
      'id': 3,
      'room': 'B201',
      'tenantName': 'วิชัย',
      'category': 'ประปา',
      'urgency': 'ด่วน',
      'detail': 'ท่อน้ำรั่วใต้อ่าง',
      'allowEnter': true,
      'status': 'in_progress',
      'createdAt': '2026-11-02T00:00:00.000',
    });
    expect(repair.id, '3');
    expect(repair.allowEnter, true);
    expect(repair.toJson()['status'], 'in_progress');
    expect(repairStatusStep(repair.status), 1);

    final RepairData empty = RepairData.fromJson({'id': 4});
    expect(empty.status, repairPending);
    expect(empty.allowEnter, false);
  });

  test('AnnouncementData fromJson / toJson', () {
    final AnnouncementData announcement = AnnouncementData.fromJson({
      'id': 1,
      'title': 'ปิดน้ำ',
      'content': 'ปิดน้ำวันเสาร์',
      'isImportant': true,
    });
    expect(announcement.isImportant, true);
    expect(announcement.toJson()['title'], 'ปิดน้ำ');
  });

  test('UserData fromJson / toJson', () {
    final UserData user = UserData.fromJson({
      'id': 2,
      'username': 'somchai',
      'password': '1234',
      'name': 'สมชาย',
      'role': 'tenant',
      'room': 'A101',
      'phone': '089',
    });
    expect(user.id, '2');
    expect(user.toJson()['room'], 'A101');
    expect(user.toJson().containsKey('id'), false);
  });

  test('จัดรูปแบบเงินและวันที่', () {
    expect(formatMoney(4260), '฿4,260.00');
    expect(formatMoney(0), '฿0.00');
    expect(formatMoney(1234567.5), '฿1,234,567.50');
    expect(
      formatDateTime(DateTime(2026, 11, 13, 14, 5)),
      '13 พ.ย. 2569 14:05 น.',
    );
  });

  test('ข้อความและลำดับของสถานะ', () {
    expect(billStatusText(billUnpaid), 'ค้างชำระ');
    expect(billStatusText(billPending), 'รอตรวจสอบ');
    expect(billStatusText(billPaid), 'ชำระแล้ว');
    expect(repairStatusText(repairDone), 'ซ่อมเสร็จแล้ว');
    expect(repairStatusStep(repairPending), 0);
    expect(repairStatusStep(repairDone), 2);
  });
}
