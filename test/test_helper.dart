import 'dart:convert';
import 'dart:io';

import 'package:dorm_app/main.dart';
import 'package:dorm_app/service/api_client.dart' as api;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

// json-server จำลองสำหรับเทสต์ ทำงานเหมือน json-server 0.17 เท่าที่แอปใช้
// - GET /collection?field=value  กรองแบบเท่ากับ
// - POST /collection             สร้าง id ใหม่ ตอบ 201
// - PATCH /collection/{id}       แก้บางช่อง ตอบ 200 (ไม่พบ id ตอบ 404)
// - DELETE /collection/{id}      ตอบ 200 (ไม่พบ id ตอบ 404)
// ข้อมูลตั้งต้นอ่านจาก server/db.sample.json ชุดเดียวกับที่ใช้เดโม
class FakeJsonServer {
  final Map<String, List<Map<String, dynamic>>> db = {};
  final List<String> requests = []; // เช่น 'PATCH /bills/4'
  bool isDown = false; // true = จำลองว่ายังไม่ได้เปิด server

  FakeJsonServer({bool empty = false}) {
    final Map<String, dynamic> sample = jsonDecode(
      File('server/db.sample.json').readAsStringSync(),
    );
    sample.forEach((String name, dynamic rows) {
      db[name] = empty
          ? []
          : (rows as List).map((r) => Map<String, dynamic>.from(r)).toList();
    });
  }

  List<Map<String, dynamic>> table(String name) => db[name]!;

  Map<String, dynamic>? findById(String name, String id) {
    for (final row in table(name)) {
      if (row['id'].toString() == id) return row;
    }
    return null;
  }

  int count(String name, Map<String, Object> where) {
    return table(name).where((row) {
      return where.entries.every((e) => row[e.key] == e.value);
    }).length;
  }

  MockClient get client => MockClient(handle);

  Future<http.Response> handle(http.Request request) async {
    if (isDown) {
      throw http.ClientException('Connection refused', request.url);
    }
    final List<String> parts = request.url.pathSegments;
    requests.add('${request.method} ${request.url.path}');
    final String name = parts.first;
    if (!db.containsKey(name)) return http.Response('{}', 404);

    final String? id = parts.length > 1 ? parts[1] : null;
    switch (request.method) {
      case 'GET':
        final rows = table(name).where((row) {
          return request.url.queryParameters.entries.every(
            (e) => row[e.key].toString() == e.value,
          );
        }).toList();
        return json(rows, 200);
      case 'POST':
        final Map<String, dynamic> body = jsonDecode(request.body);
        int nextId = 1;
        for (final row in table(name)) {
          final int rowId = int.parse(row['id'].toString());
          if (rowId >= nextId) nextId = rowId + 1;
        }
        body['id'] = nextId;
        table(name).add(body);
        return json(body, 201);
      case 'PATCH':
        final row = findById(name, id!);
        if (row == null) return http.Response('{}', 404);
        row.addAll(jsonDecode(request.body));
        return json(row, 200);
      case 'DELETE':
        final row = findById(name, id!);
        if (row == null) return http.Response('{}', 404);
        table(name).remove(row);
        return json({}, 200);
    }
    return http.Response('{}', 405);
  }

  http.Response json(Object data, int status) {
    return http.Response.bytes(
      utf8.encode(jsonEncode(data)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

// ตั้งค่าให้แอปเรียก server จำลอง และล้าง shared_preferences
FakeJsonServer setUpFakeServer({
  bool empty = false,
  Map<String, Object> prefs = const {},
}) {
  SharedPreferences.setMockInitialValues(prefs);
  final FakeJsonServer server = FakeJsonServer(empty: empty);
  api.client = server.client;
  // ให้บิลเดือนนี้ของ A101 ตรงกับเดือน/ปีปัจจุบันเสมอ (ใช้ทดสอบการกันออกบิลซ้ำ)
  final DateTime now = DateTime.now();
  final bill = server.findById('bills', '4');
  if (bill != null) {
    bill['month'] = now.month;
    bill['year'] = now.year + 543;
  }
  return server;
}

// ตั้งขนาดจอทดสอบให้เท่ามือถือ (411 x 891)
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

// เปิดแอป แล้วรอให้หน้า Splash ทำงานจนเปลี่ยนหน้าเสร็จ
Future<void> openApp(WidgetTester tester) async {
  usePhoneScreen(tester);
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 1500));
  await tester.pumpAndSettle();
}

// กรอกชื่อผู้ใช้/รหัสผ่าน แล้วกดเข้าสู่ระบบ
Future<void> login(
  WidgetTester tester,
  String username,
  String password,
) async {
  await tester.enterText(find.byType(TextFormField).at(0), username);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'));
  await tester.pumpAndSettle();
}

// ดึงรายการลงเพื่อโหลดใหม่ (RefreshIndicator)
Future<void> pullToRefresh(WidgetTester tester) async {
  // ใช้รายการแนวตั้งตัวสุดท้ายใน RefreshIndicator (ข้ามแถบตัวกรองที่เลื่อนแนวนอน)
  final Finder list = find
      .descendant(
        of: find.byType(RefreshIndicator),
        matching: find.byType(Scrollable),
      )
      .last;
  await tester.fling(list, const Offset(0, 500), 1000);
  await tester.pumpAndSettle();
}

// ปิด SnackBar ที่ค้างอยู่ เพื่อไม่ให้บังปุ่มด้านล่างจอในขั้นถัดไป
Future<void> hideSnackBar(WidgetTester tester) async {
  final BuildContext context = tester.element(find.byType(Scaffold).first);
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  await tester.pumpAndSettle();
}
