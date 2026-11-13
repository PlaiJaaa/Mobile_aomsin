import 'dart:convert';

import 'package:dorm_app/constant/api_config.dart';
import 'package:dorm_app/model/bill_data.dart';
import 'package:dorm_app/service/api_client.dart' as api;
import 'package:dorm_app/service/bill_service.dart';
import 'package:dorm_app/service/user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// ทดสอบว่า service เรียก URL / method / body ถูกต้อง และจัดการ statusCode กับ error
void main() {
  test('login เรียก GET /users?username=... แล้วเทียบรหัสผ่าน', () async {
    late Uri calledUrl;
    api.client = MockClient((request) async {
      calledUrl = request.url;
      return http.Response.bytes(
        utf8.encode(
          jsonEncode([
            {
              'id': 2,
              'username': 'somchai',
              'password': '1234',
              'name': 'สมชาย',
              'role': 'tenant',
              'room': 'A101',
              'phone': '',
            },
          ]),
        ),
        200,
      );
    });

    final service = UserService();
    expect((await service.login('somchai', '1234'))!.name, 'สมชาย');
    expect(calledUrl.toString(), '$baseUrl/users?username=somchai');
    expect(await service.login('somchai', 'wrong'), isNull);
  });

  test('createBill ส่ง POST พร้อม JSON และต้องได้ 201', () async {
    late http.Request sent;
    api.client = MockClient((request) async {
      sent = request;
      return http.Response('{"id": 9}', 201);
    });

    await BillService().createBill(
      BillData(
        id: '',
        room: 'A101',
        month: 12,
        year: 2569,
        rent: 3500,
        water: 0,
        electric: 0,
        status: 'unpaid',
        paymentRef: '',
        createdAt: DateTime(2026, 12, 1),
      ),
    );
    expect(sent.method, 'POST');
    expect(sent.url.toString(), '$baseUrl/bills');
    expect(sent.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(sent.body)['room'], 'A101');
    expect(jsonDecode(sent.body).containsKey('id'), false);
  });

  test('submitPayment ส่ง PATCH เฉพาะช่องที่เปลี่ยน', () async {
    late http.Request sent;
    api.client = MockClient((request) async {
      sent = request;
      return http.Response('{}', 200);
    });

    await BillService().submitPayment('4', 'TRX123456');
    expect(sent.method, 'PATCH');
    expect(sent.url.toString(), '$baseUrl/bills/4');
    expect(jsonDecode(sent.body), {
      'status': 'pending',
      'paymentRef': 'TRX123456',
    });
  });

  test('statusCode ผิดปกติ -> ApiException พร้อมรหัส', () async {
    api.client = MockClient((request) async => http.Response('{}', 404));
    expect(
      () => BillService().deleteBill('999'),
      throwsA(
        isA<api.ApiException>().having(
          (e) => e.message,
          'message',
          contains('404'),
        ),
      ),
    );
  });

  test('ต่อ server ไม่ได้ -> ข้อความให้เปิด server ก่อน', () async {
    api.client = MockClient((request) async {
      throw http.ClientException('Connection refused', request.url);
    });
    expect(
      () => BillService().getAllBills(),
      throwsA(
        isA<api.ApiException>().having(
          (e) => e.message,
          'message',
          api.serverDownMessage,
        ),
      ),
    );
  });
}
