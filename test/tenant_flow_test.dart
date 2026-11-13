import 'package:dorm_app/service/api_client.dart' as api;
import 'package:dorm_app/widgets/bill_card.dart';
import 'package:dorm_app/widgets/repair_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helper.dart';

// ไล่ flow ฝั่งผู้เช่ากับ json-server จำลอง
void main() {
  setUpAll(() async {
    await initializeDateFormatting('th');
  });

  // ผู้ใช้ที่จำไว้ในเครื่อง (ข้ามหน้า Login)
  Map<String, Object> rememberedUser(
    String username,
    String name,
    String room,
  ) {
    return {
      'userId': '9',
      'username': username,
      'name': name,
      'role': 'tenant',
      'room': room,
      'phone': '',
    };
  }

  testWidgets('เข้าสู่ระบบ: validate ฟอร์ม และรหัสผ่านผิดต้องแจ้งเตือน', (
    tester,
  ) async {
    final FakeJsonServer server = setUpFakeServer();
    await openApp(tester);

    // ยังไม่กรอกอะไร -> validator ต้องเตือน และยังไม่เรียก API
    await tester.tap(find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'));
    await tester.pumpAndSettle();
    expect(find.text('กรุณากรอกชื่อผู้ใช้'), findsOneWidget);
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);
    expect(server.requests, isEmpty);

    // รหัสผ่านสั้นเกินไป
    await login(tester, 'somchai', '12');
    expect(find.text('รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร'), findsOneWidget);

    // รหัสผ่านผิด -> SnackBar และยังอยู่หน้าเดิม
    await login(tester, 'somchai', 'wrong');
    expect(find.text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'), findsOneWidget);
    expect(server.requests.last, 'GET /users');
  });

  testWidgets('ยังไม่เปิด server: แจ้งให้เปิด server ก่อน และกดลองใหม่ได้', (
    tester,
  ) async {
    final FakeJsonServer server = setUpFakeServer();
    server.isDown = true;
    await openApp(tester);

    // เข้าสู่ระบบไม่ได้ -> SnackBar บอกให้เปิด server
    await login(tester, 'somchai', '1234');
    expect(find.text(api.serverDownMessage), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'), findsOneWidget);
  });

  testWidgets('ยังไม่เปิด server: หน้าหลักแสดง error แล้วกดลองใหม่หลังเปิด', (
    tester,
  ) async {
    final FakeJsonServer server = setUpFakeServer(
      prefs: rememberedUser('somchai', 'สมชาย ใจดี', 'A101'),
    );
    server.isDown = true;
    await openApp(tester);

    expect(find.text('โหลดข้อมูลไม่สำเร็จ'), findsOneWidget);
    expect(find.text(api.serverDownMessage), findsOneWidget);

    // เปิด server แล้วกดลองใหม่ -> เห็นข้อมูล
    server.isDown = false;
    await tester.tap(find.text('ลองใหม่'));
    await tester.pumpAndSettle();
    expect(find.text('฿4,260.00'), findsOneWidget);
  });

  testWidgets('ผู้เช่า: หน้าหลักแสดงยอดค้าง แล้วแจ้งชำระด้วยเลขอ้างอิง', (
    tester,
  ) async {
    final FakeJsonServer server = setUpFakeServer();
    await openApp(tester);
    await login(tester, 'somchai', '1234');

    // หน้าหลัก: ชื่อ ห้อง ยอดค้างชำระของ A101 (3500 + 120 + 640) และประกาศล่าสุด
    expect(find.text('สมชาย ใจดี'), findsOneWidget);
    expect(find.text('ห้อง A101'), findsOneWidget);
    expect(find.text('฿4,260.00'), findsOneWidget);
    expect(find.text('มี 1 บิลที่ยังไม่ได้ชำระ'), findsOneWidget);
    expect(find.text('แจ้งปิดน้ำชั่วคราวเพื่อล้างถังเก็บน้ำ'), findsOneWidget);

    // ไปเมนูบิลจากปุ่มในการ์ดสรุป
    await tester.tap(find.text('ดูบิลและแจ้งชำระ'));
    await tester.pumpAndSettle();
    expect(find.text('บิลของห้อง A101'), findsOneWidget);
    expect(find.byType(BillCard), findsNWidgets(2));
    expect(find.text('ค้างชำระ'), findsOneWidget);
    expect(find.text('ชำระแล้ว'), findsOneWidget);

    // เปิดบิลใบแรก (รอบล่าสุด = ค้างชำระ)
    await tester.tap(find.byType(BillCard).first);
    await tester.pumpAndSettle();
    expect(find.text('รายละเอียดบิล'), findsOneWidget);
    expect(find.text('฿3,500.00'), findsOneWidget);

    // ไม่กรอกเลขอ้างอิง -> validator เตือน
    await tester.tap(find.widgetWithText(FilledButton, 'แจ้งชำระเงิน'));
    await tester.pumpAndSettle();
    expect(find.text('กรุณากรอกเลขอ้างอิงการโอน'), findsOneWidget);

    // เลขอ้างอิงสั้นเกินไป
    await tester.enterText(find.byType(TextFormField), '123');
    await tester.tap(find.widgetWithText(FilledButton, 'แจ้งชำระเงิน'));
    await tester.pumpAndSettle();
    expect(find.text('เลขอ้างอิงต้องมีอย่างน้อย 6 ตัวอักษร'), findsOneWidget);

    // กรอกถูกต้อง -> Dialog ยืนยัน -> กดยกเลิกก่อน ต้องยังไม่ส่ง PATCH
    await tester.enterText(find.byType(TextFormField), 'TRX99887766');
    await tester.tap(find.widgetWithText(FilledButton, 'แจ้งชำระเงิน'));
    await tester.pumpAndSettle();
    expect(find.text('ยืนยันการแจ้งชำระ'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'ยกเลิก'));
    await tester.pumpAndSettle();
    expect(server.requests.where((r) => r.startsWith('PATCH')), isEmpty);

    // กดยืนยันจริง
    await tester.tap(find.widgetWithText(FilledButton, 'แจ้งชำระเงิน'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'แจ้งชำระ'));
    await tester.pumpAndSettle();

    // ส่ง PATCH /bills/4 แล้วกลับมาหน้ารายการที่โหลดใหม่
    expect(server.requests, contains('PATCH /bills/4'));
    expect(find.text('แจ้งชำระเรียบร้อย รอผู้ดูแลตรวจสอบ'), findsOneWidget);
    expect(find.text('บิลของห้อง A101'), findsOneWidget);
    expect(find.text('รอตรวจสอบ'), findsOneWidget);
    expect(find.text('ค้างชำระ'), findsNothing);

    // ข้อมูลใน server ถูกแก้จริง
    final bill = server.findById('bills', '4')!;
    expect(bill['status'], 'pending');
    expect(bill['paymentRef'], 'TRX99887766');

    // กลับหน้าหลัก ยอดค้างต้องเป็น 0
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('฿0.00'), findsOneWidget);
    expect(find.text('แจ้งชำระแล้ว รอผู้ดูแลตรวจสอบ 1 บิล'), findsOneWidget);
  });

  testWidgets('ผู้เช่า: แจ้งซ่อมใหม่ และดึงลงเพื่อดูสถานะล่าสุด', (
    tester,
  ) async {
    final FakeJsonServer server = setUpFakeServer();
    await openApp(tester);
    await login(tester, 'somchai', '1234');

    await tester.tap(find.byIcon(Icons.build_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(RepairCard), findsNWidgets(2)); // ของ A101 มี 2 รายการ

    // เปิดฟอร์มแจ้งซ่อม
    await tester.tap(find.text('แจ้งซ่อมใหม่'));
    await tester.pumpAndSettle();

    final Finder submit = find.widgetWithText(
      FilledButton,
      'ส่งเรื่องแจ้งซ่อม',
    );

    // ส่งทั้งที่ยังไม่กรอก -> validator เตือน
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('กรุณาเลือกหมวดหมู่ปัญหา'), findsOneWidget);
    expect(find.text('กรุณากรอกรายละเอียดปัญหา'), findsOneWidget);

    // เลือกหมวดหมู่จาก Dropdown
    await tester.ensureVisible(find.text('หมวดหมู่ปัญหา'));
    await tester.tap(find.text('หมวดหมู่ปัญหา'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ประปา').last);
    await tester.pumpAndSettle();

    // เลือกความเร่งด่วนจาก Radio
    await tester.tap(find.text('ด่วนมาก'));
    await tester.pumpAndSettle();

    // รายละเอียด + เปิด Switch
    await tester.enterText(
      find.byType(TextFormField),
      'ชักโครกกดน้ำไม่ลง น้ำไหลไม่หยุด',
    );
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    // POST แล้วกลับมาหน้ารายการที่โหลดใหม่ มี 3 รายการ
    expect(server.requests, contains('POST /repairs'));
    expect(find.text('ส่งเรื่องแจ้งซ่อมเรียบร้อย'), findsOneWidget);
    expect(find.byType(RepairCard), findsNWidgets(3));
    expect(find.text('ชักโครกกดน้ำไม่ลง น้ำไหลไม่หยุด'), findsOneWidget);

    // ข้อมูลที่บันทึกใน server ครบทุกช่อง
    final created = server.table('repairs').last;
    expect(created['id'], 5);
    expect(created['room'], 'A101');
    expect(created['tenantName'], 'สมชาย ใจดี');
    expect(created['category'], 'ประปา');
    expect(created['urgency'], 'ด่วนมาก');
    expect(created['allowEnter'], true);
    expect(created['status'], 'pending');
    await hideSnackBar(tester);

    // จำลองผู้ดูแลปิดงานที่ server -> ผู้เช่าดึงลงแล้วเห็นสถานะใหม่
    expect(find.text('ซ่อมเสร็จแล้ว'), findsNothing);
    created['status'] = 'done';
    await pullToRefresh(tester);
    expect(server.requests.last, 'GET /repairs');
    expect(
      find.descendant(
        of: find.byType(RepairCard).first,
        matching: find.text('เสร็จแล้ว'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('ผู้เช่า: ประกาศ โปรไฟล์ สลับธีม และออกจากระบบ', (tester) async {
    setUpFakeServer();
    await openApp(tester);
    await login(tester, 'malee', '1234');

    // ติ๊กจดจำไว้ (ค่าเริ่มต้น) -> ต้องบันทึกผู้ใช้ลงเครื่อง โดยไม่มีรหัสผ่าน
    SharedPreferences prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('username'), 'malee');
    expect(prefs.getString('room'), 'A102');
    expect(prefs.getKeys().contains('password'), false);

    // เมนูประกาศ: เห็นครบ 3 ประกาศ และผู้เช่าต้องไม่มีปุ่มลบ/ลงประกาศ
    await tester.tap(find.byIcon(Icons.campaign_outlined));
    await tester.pumpAndSettle();
    expect(find.text('ประกาศจากหอพัก'), findsOneWidget);
    expect(find.text('กำหนดชำระค่าเช่าประจำเดือน'), findsOneWidget);
    expect(find.text('ประกาศสำคัญ'), findsOneWidget);
    expect(find.text('ลบประกาศ'), findsNothing);
    expect(find.text('ลงประกาศ'), findsNothing);

    // เมนูโปรไฟล์
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('มาลี รักเรียน'), findsOneWidget);
    expect(find.text('ผู้เช่า ห้อง A102'), findsOneWidget);

    // สลับเป็นโหมดมืด -> ธีมเปลี่ยน และจำค่าไว้ในเครื่อง
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    final BuildContext context = tester.element(find.text('โหมดมืด'));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(prefs.getBool('isDarkMode'), true);

    // ออกจากระบบ: กดยกเลิกก่อน ต้องยังอยู่หน้าเดิม
    await tester.ensureVisible(find.text('ออกจากระบบ'));
    await tester.tap(find.text('ออกจากระบบ'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'ยกเลิก'));
    await tester.pumpAndSettle();
    expect(find.text('มาลี รักเรียน'), findsOneWidget);

    // ออกจากระบบจริง -> กลับหน้า Login และลบผู้ใช้ที่จำไว้
    await tester.tap(find.text('ออกจากระบบ'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ออกจากระบบ'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'), findsOneWidget);
    expect(prefs.getString('userId'), null);
  });

  testWidgets('จำการเข้าสู่ระบบ: เปิดแอปใหม่แล้วเข้าหน้าหลักเลย', (
    tester,
  ) async {
    final Map<String, Object> prefs = rememberedUser(
      'wichai',
      'วิชัย ตั้งใจ',
      'B201',
    );
    prefs['isDarkMode'] = true;
    setUpFakeServer(prefs: prefs);

    await openApp(tester);

    // ไม่ผ่านหน้า Login และยอดค้างของ B201 = 5205 + 5260
    expect(find.text('วิชัย ตั้งใจ'), findsOneWidget);
    expect(find.text('฿10,465.00'), findsOneWidget);
    expect(find.text('มี 2 บิลที่ยังไม่ได้ชำระ'), findsOneWidget);
    final BuildContext context = tester.element(find.text('วิชัย ตั้งใจ'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('ข้อมูลว่าง: ทุกหน้าของผู้เช่าแสดงสถานะว่าง ไม่พัง', (
    tester,
  ) async {
    setUpFakeServer(
      empty: true,
      prefs: rememberedUser('new', 'ผู้เช่าใหม่', 'C301'),
    );

    await openApp(tester);
    expect(find.text('฿0.00'), findsOneWidget);
    expect(find.text('ไม่มียอดค้างชำระ ขอบคุณที่ชำระตรงเวลา'), findsOneWidget);
    expect(find.text('ยังไม่มีประกาศ'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.receipt_long_outlined));
    await tester.pumpAndSettle();
    expect(find.text('ยังไม่มีบิล'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.build_outlined));
    await tester.pumpAndSettle();
    expect(find.text('ยังไม่มีรายการแจ้งซ่อม'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.campaign_outlined));
    await tester.pumpAndSettle();
    expect(find.text('ยังไม่มีประกาศ'), findsOneWidget);
  });
}
