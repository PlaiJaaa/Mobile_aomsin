import 'package:dorm_app/widgets/announcement_card.dart';
import 'package:dorm_app/widgets/bill_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'test_helper.dart';

// ไล่ flow ฝั่งผู้ดูแลกับ json-server จำลอง
void main() {
  setUpAll(() async {
    await initializeDateFormatting('th');
  });

  testWidgets('ผู้ดูแล: กรองบิล ยืนยันการชำระ ตีกลับ และลบบิล', (tester) async {
    final FakeJsonServer server = setUpFakeServer();
    await openApp(tester);
    await login(tester, 'admin', 'admin1234');

    // เข้าหน้าจัดการบิล เห็นจำนวนตามสถานะของข้อมูลตัวอย่าง
    expect(find.text('จัดการบิล'), findsOneWidget);
    expect(find.text('ทั้งหมด (6)'), findsOneWidget);
    expect(find.text('รอตรวจสอบ (1)'), findsOneWidget);
    expect(find.text('ค้างชำระ (3)'), findsOneWidget);
    expect(find.text('ชำระแล้ว (2)'), findsOneWidget);

    // กรองเฉพาะรอตรวจสอบ -> เหลือ 1 ใบ (ห้อง A102)
    await tester.tap(find.text('รอตรวจสอบ (1)'));
    await tester.pumpAndSettle();
    expect(find.byType(BillCard), findsOneWidget);
    expect(find.text('ห้อง A102'), findsOneWidget);
    expect(find.text('เลขอ้างอิง TRX0007654321'), findsOneWidget);

    // ตรวจสอบ -> ไม่พบยอดโอน -> กลับเป็นค้างชำระ
    await tester.tap(find.text('ตรวจสอบการชำระ').first);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('ได้รับเงินโอนรายการนี้แล้วใช่หรือไม่'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'ไม่พบยอดโอน'));
    await tester.pumpAndSettle();
    expect(server.requests, contains('PATCH /bills/5'));
    expect(server.count('bills', {'status': 'pending'}), 0);
    expect(server.count('bills', {'status': 'unpaid'}), 4);
    expect(find.text('ไม่มีบิลในสถานะนี้'), findsOneWidget);
    await hideSnackBar(tester);

    // จำลองผู้เช่าแจ้งชำระเข้ามาใหม่ที่ server -> ดึงลงแล้วรายการโผล่
    server.findById('bills', '5')!
      ..['status'] = 'pending'
      ..['paymentRef'] = 'NEWREF123456';
    await pullToRefresh(tester);
    expect(find.text('เลขอ้างอิง NEWREF123456'), findsOneWidget);

    // ตรวจสอบ -> ยืนยันรับชำระ
    await tester.tap(find.text('ตรวจสอบการชำระ').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ยืนยันรับชำระ'));
    await tester.pumpAndSettle();
    expect(find.text('ยืนยันการชำระห้อง A102 แล้ว'), findsOneWidget);
    expect(server.findById('bills', '5')!['status'], 'paid');
    expect(server.count('bills', {'status': 'paid'}), 3);
    await hideSnackBar(tester);

    // กรองค้างชำระ แล้วลบบิลใบแรก (กดยกเลิกก่อน แล้วค่อยลบจริง)
    // แถบตัวกรองเลื่อนแนวนอนได้ จึงเลื่อนให้เห็นปุ่มก่อนกด
    await tester.ensureVisible(find.text('ค้างชำระ (3)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ค้างชำระ (3)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ลบบิล').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'ยกเลิก'));
    await tester.pumpAndSettle();
    expect(server.count('bills', {'status': 'unpaid'}), 3);

    await tester.tap(find.text('ลบบิล').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ลบ'));
    await tester.pumpAndSettle();
    expect(server.requests.where((r) => r.startsWith('DELETE')).length, 1);
    expect(find.text('ลบบิลเรียบร้อย'), findsOneWidget);
    expect(server.count('bills', {'status': 'unpaid'}), 2);
    expect(find.text('ค้างชำระ (2)'), findsOneWidget);
  });

  testWidgets('ผู้ดูแล: ออกบิลใหม่ validate ฟอร์ม และกันบิลซ้ำ', (
    tester,
  ) async {
    final FakeJsonServer server = setUpFakeServer();
    await openApp(tester);
    await login(tester, 'admin', 'admin1234');

    await tester.tap(find.text('ออกบิล'));
    await tester.pumpAndSettle();
    expect(find.text('ออกบิลใหม่'), findsOneWidget);
    expect(server.requests.last, 'GET /users'); // โหลดเลขห้องของผู้เช่า

    Future<void> tapSubmit() async {
      final Finder button = find.widgetWithText(FilledButton, 'ออกบิล');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    // ส่งทั้งที่ยังไม่กรอก
    await tapSubmit();
    expect(find.text('กรุณาเลือกห้องพัก'), findsOneWidget);
    expect(find.text('กรุณากรอกค่าเช่าห้อง'), findsOneWidget);
    expect(find.text('กรุณากรอกค่าน้ำ'), findsOneWidget);
    expect(find.text('กรุณากรอกค่าไฟ'), findsOneWidget);

    // เลือกห้องจาก Dropdown (ตัวเลือกมาจากผู้เช่าใน server)
    await tester.ensureVisible(find.text('ห้องพัก'));
    await tester.tap(find.text('ห้องพัก'));
    await tester.pumpAndSettle();
    expect(find.text('ห้อง A102'), findsWidgets);
    expect(find.text('ห้อง B201'), findsWidgets);
    await tester.tap(find.text('ห้อง A101').last);
    await tester.pumpAndSettle();

    // กรอกเงินผิดรูปแบบ
    await tester.enterText(find.byType(TextFormField).at(1), 'abc');
    await tester.enterText(find.byType(TextFormField).at(2), '-5');
    await tester.enterText(find.byType(TextFormField).at(3), '0');
    await tapSubmit();
    expect(find.text('ค่าเช่าห้องต้องเป็นตัวเลข'), findsOneWidget);
    expect(find.text('ค่าน้ำต้องไม่ติดลบ'), findsOneWidget);

    // กรอกถูกต้อง ยอดรวมต้องคำนวณทันที
    await tester.enterText(find.byType(TextFormField).at(1), '3500');
    await tester.enterText(find.byType(TextFormField).at(2), '100');
    await tester.enterText(find.byType(TextFormField).at(3), '400.50');
    await tester.pumpAndSettle();
    expect(find.text('฿4,000.50'), findsOneWidget);

    // A101 มีบิลเดือนนี้อยู่แล้ว -> ต้องไม่ยอมออกซ้ำ
    await tapSubmit();
    expect(find.textContaining('มีบิลรอบ'), findsOneWidget);
    expect(server.table('bills').length, 6);
    expect(server.requests.where((r) => r.startsWith('POST')), isEmpty);
    await hideSnackBar(tester);

    // เปลี่ยนปีเป็นปีถัดไป -> ออกบิลได้
    final String nextYear = (DateTime.now().year + 544).toString();
    await tester.enterText(find.byType(TextFormField).at(0), nextYear);
    await tapSubmit();
    expect(server.requests, contains('POST /bills'));
    expect(find.text('ออกบิลห้อง A101 เรียบร้อย'), findsOneWidget);
    expect(find.text('จัดการบิล'), findsOneWidget);
    expect(find.text('ทั้งหมด (7)'), findsOneWidget); // รายการโหลดใหม่แล้ว

    final created = server.table('bills').last;
    expect(created['id'], 7);
    expect(created['room'], 'A101');
    expect(created['year'], int.parse(nextYear));
    expect(created['status'], 'unpaid');
    expect(created['electric'], 400.5);
  });

  testWidgets('ผู้ดูแล: เปลี่ยนสถานะงานซ่อมทีละขั้น', (tester) async {
    final FakeJsonServer server = setUpFakeServer();
    await openApp(tester);
    await login(tester, 'admin', 'admin1234');

    await tester.tap(find.byIcon(Icons.build_outlined));
    await tester.pumpAndSettle();
    expect(find.text('จัดการงานซ่อม'), findsOneWidget);
    expect(server.count('repairs', {'status': 'pending'}), 2);
    expect(server.count('repairs', {'status': 'in_progress'}), 1);

    // รายการแรก (แจ้งล่าสุด = B201 อินเทอร์เน็ต) : รับงาน
    expect(find.text('ห้อง B201 · วิชัย ตั้งใจ'), findsOneWidget);
    await tester.tap(find.text('รับงาน เริ่มซ่อม').first);
    await tester.pumpAndSettle();
    expect(find.text('เปลี่ยนสถานะงานซ่อม'), findsOneWidget);

    // กดยกเลิกก่อน ต้องไม่เปลี่ยน
    await tester.tap(find.widgetWithText(TextButton, 'ยกเลิก'));
    await tester.pumpAndSettle();
    expect(server.count('repairs', {'status': 'pending'}), 2);

    await tester.tap(find.text('รับงาน เริ่มซ่อม').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ยืนยัน'));
    await tester.pumpAndSettle();
    expect(server.requests, contains('PATCH /repairs/4'));
    expect(server.findById('repairs', '4')!['status'], 'in_progress');
    await hideSnackBar(tester);

    // รายการเดิมมีปุ่มปิดงานแทน -> ปิดงาน
    await tester.tap(find.text('ปิดงาน ซ่อมเสร็จแล้ว').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ยืนยัน'));
    await tester.pumpAndSettle();
    expect(server.findById('repairs', '4')!['status'], 'done');
    expect(server.count('repairs', {'status': 'done'}), 2);
  });

  testWidgets('ผู้ดูแล: ลงประกาศใหม่ และลบประกาศ', (tester) async {
    final FakeJsonServer server = setUpFakeServer();
    await openApp(tester);
    await login(tester, 'admin', 'admin1234');

    await tester.tap(find.byIcon(Icons.campaign_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(AnnouncementCard), findsNWidgets(3));

    // เปิดฟอร์มลงประกาศ
    await tester.tap(find.text('ลงประกาศ'));
    await tester.pumpAndSettle();
    expect(find.text('ลงประกาศใหม่'), findsOneWidget);

    // ส่งทั้งที่ยังไม่กรอก
    await tester.tap(find.widgetWithText(FilledButton, 'ลงประกาศ'));
    await tester.pumpAndSettle();
    expect(find.text('กรุณากรอกหัวข้อประกาศ'), findsOneWidget);
    expect(find.text('กรุณากรอกเนื้อหาประกาศ'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'ปิดลิฟต์ซ่อมบำรุง',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'ลิฟต์จะปิดซ่อมบำรุงวันจันทร์ 09:00-12:00 น.',
    );
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ลงประกาศ'));
    await tester.pumpAndSettle();

    // กลับมาหน้ารายการที่โหลดใหม่ ประกาศใหม่อยู่บนสุด
    expect(server.requests, contains('POST /announcements'));
    expect(find.text('ลงประกาศเรียบร้อย'), findsOneWidget);
    expect(find.byType(AnnouncementCard), findsNWidgets(4));
    expect(find.text('ปิดลิฟต์ซ่อมบำรุง'), findsOneWidget);
    final created = server.table('announcements').last;
    expect(created['id'], 4);
    expect(created['isImportant'], true);
    await hideSnackBar(tester);

    // ลบประกาศที่เพิ่งลง (อยู่บนสุด)
    await tester.tap(find.text('ลบประกาศ').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('ปิดลิฟต์ซ่อมบำรุง'), findsWidgets);
    await tester.tap(find.widgetWithText(FilledButton, 'ลบ'));
    await tester.pumpAndSettle();
    expect(server.requests, contains('DELETE /announcements/4'));
    expect(find.text('ลบประกาศเรียบร้อย'), findsOneWidget);
    expect(server.table('announcements').length, 3);
    expect(find.text('ปิดลิฟต์ซ่อมบำรุง'), findsNothing);
  });

  testWidgets('ผู้ดูแล: โปรไฟล์แสดงบทบาทผู้ดูแล', (tester) async {
    setUpFakeServer();
    await openApp(tester);
    await login(tester, 'admin', 'admin1234');

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('สมศรี ดูแลดี'), findsOneWidget);
    expect(find.text('ผู้ดูแลหอพัก'), findsOneWidget);
    expect(find.text('ห้องพัก'), findsNothing); // ผู้ดูแลไม่มีเลขห้อง
  });
}
