# หอพักอุ่นใจ (dorm_app)

Project รายวิชา Mobile Development เขียนด้วย Flutter
ใช้ REST API จาก **json-server** (ข้อมูลผู้ใช้ บิล งานซ่อม ประกาศ) มีระบบเข้าสู่ระบบแยก 2 บทบาท คือ **ผู้เช่า** และ **ผู้ดูแลหอ**
ไม่ใช้ Firebase และจัดการ state ด้วย `StatefulWidget` + `setState` เท่านั้น

## วิธีรันแบบเร็วที่สุด

ดับเบิลคลิก **`run_all.bat`** ครั้งเดียว จะเปิด server (หน้าต่างแยกชื่อ "dorm_app server") เปิด Android Emulator แล้วรันแอปให้เอง
ครั้งแรกใช้เวลาประมาณ 3-7 นาที (ต้องต่ออินเทอร์เน็ต) ครั้งต่อไปเร็วขึ้นมาก
ถ้าอยากรันบน Chrome หรือทำทีละขั้น และวิธีแก้ปัญหา ดู [HOW_TO_RUN.md](HOW_TO_RUN.md)

- **อย่าปิดหน้าต่าง "dorm_app server"** ระหว่างใช้แอป ปิดแอปกด `q` ในหน้าต่าง `run_all.bat`
- ล้างข้อมูลกลับเป็นค่าเริ่มต้นหลังทดลองใช้: ดับเบิลคลิก **`reset_data.bat`**

> server ของแอปนี้ใช้ **port 3000** ถ้าจะเปิดพร้อมแอปอื่น แอปนั้นต้องใช้ port อื่น (เช่น Travel Planner ใช้ 3001)

ต้องติดตั้ง Flutter SDK 3.32 ขึ้นไป, Node.js 18 ขึ้นไป และ Android Studio (มี emulator อย่างน้อย 1 เครื่อง) ไว้ก่อน รายละเอียดอยู่ใน HOW_TO_RUN.md

### บัญชีทดสอบ

| บทบาท | ชื่อผู้ใช้ | รหัสผ่าน | ห้อง |
| --- | --- | --- | --- |
| ผู้ดูแล | `admin` | `admin1234` | - |
| ผู้เช่า | `somchai` | `1234` | A101 |
| ผู้เช่า | `malee` | `1234` | A102 |
| ผู้เช่า | `wichai` | `1234` | B201 |

## ฟีเจอร์

### ทุกบทบาท

| หน้า | สิ่งที่ทำได้ |
| --- | --- |
| Splash | โลโก้ค่อย ๆ ปรากฏ (AnimatedOpacity) แล้วเช็กว่าเคยจำการเข้าสู่ระบบไว้หรือไม่ ถ้าเคยจะเข้าหน้าหลักตามบทบาทเลย |
| เข้าสู่ระบบ | ฟอร์มชื่อผู้ใช้/รหัสผ่านพร้อม validator ปุ่มแสดง/ซ่อนรหัสผ่าน ติ๊ก "จดจำการเข้าสู่ระบบ" (shared_preferences) แจ้งเตือนเมื่อรหัสผ่านผิดหรือยังไม่เปิด server |
| ประกาศ | รายการประกาศเรียงใหม่สุดก่อน ประกาศสำคัญมีป้ายเด่น ดึงลงเพื่อโหลดใหม่ |
| โปรไฟล์ | ข้อมูลบัญชี สลับธีมสว่าง/มืด (Switch จำค่าไว้ในเครื่อง) และออกจากระบบ (ยืนยันผ่าน Dialog) |

### ผู้เช่า (BottomNavigationBar 5 เมนู)

| หน้า | สิ่งที่ทำได้ |
| --- | --- |
| หน้าหลัก | คำทักทายพร้อมเลขห้อง การ์ดยอดค้างชำระ (AnimatedContainer) ทางลัดไปแจ้งซ่อม และประกาศล่าสุด 3 รายการ |
| บิล | บิลทุกเดือนของห้องตัวเอง แตะเพื่อดูรายละเอียด (ค่าเช่า ค่าน้ำ ค่าไฟ ยอดรวม) บิลที่ค้างชำระกรอก **เลขอ้างอิงการโอน** เพื่อแจ้งชำระได้ สถานะเปลี่ยนเป็น "รอตรวจสอบ" |
| แจ้งซ่อม | รายการที่เคยแจ้งพร้อมแถบความคืบหน้า 3 ขั้น ปุ่มแจ้งซ่อมใหม่: หมวดหมู่ (Dropdown) ความเร่งด่วน (Radio) รายละเอียด (TextFormField) อนุญาตให้ช่างเข้าห้อง (Switch) |
| ประกาศ / โปรไฟล์ | อ่านประกาศอย่างเดียว / ดูข้างบน |

### ผู้ดูแลหอ (BottomNavigationBar 4 เมนู)

| หน้า | สิ่งที่ทำได้ |
| --- | --- |
| บิล | บิลทุกห้อง กรองตามสถานะ (ค้างชำระ / รอตรวจสอบ / ชำระแล้ว) พร้อมจำนวน ออกบิลใหม่ (เลือกห้อง เดือน ปี พ.ศ. กรอกค่าเช่า ค่าน้ำ ค่าไฟ เห็นยอดรวมทันที และ **กันออกบิลซ้ำ** ห้องเดียวกันเดือนเดียวกัน) ยืนยันรับเงิน / ตีกลับเมื่อไม่พบยอดโอน / ลบบิลที่ออกผิด |
| งานซ่อม | งานซ่อมทุกห้อง เลื่อนสถานะทีละขั้น รอดำเนินการ → กำลังซ่อม → ซ่อมเสร็จแล้ว (ยืนยันก่อนเปลี่ยน) |
| ประกาศ | ลงประกาศใหม่ (หัวข้อ เนื้อหา Checkbox ประกาศสำคัญ) และลบประกาศ |
| โปรไฟล์ | ดูข้างบน |

สลับเมนูด้วย AnimatedSwitcher (จางเข้า-ออก) ทุกหน้ารายการดึงลงเพื่อโหลดใหม่ได้ (RefreshIndicator)

## package ที่ใช้

| package | ใช้ทำอะไร |
| --- | --- |
| `http` | เรียก REST API (GET / POST / PATCH / DELETE) และ `MockClient` ในเทสต์ |
| `shared_preferences` | จำธีมและผู้ใช้ที่ล็อกอินค้างไว้ (ไม่เก็บรหัสผ่านลงเครื่อง) |
| `intl` | จัดรูปแบบเงินและวันที่ภาษาไทย |

ฟอนต์ไทย **Prompt** ฝังไว้ใน `assets/fonts` (สัญญาอนุญาต OFL)

## API ที่เรียก

### json-server (`server/`, `http://localhost:3000`; บน Android Emulator คือ `http://10.0.2.2:3000`)

ตั้งที่อยู่ไว้จุดเดียวใน `lib/constant/api_config.dart` (เลือก localhost / 10.0.2.2 ให้อัตโนมัติตามเครื่องที่รัน)

| Method | Endpoint | ใช้ที่ไหน | ไฟล์ service |
| --- | --- | --- | --- |
| GET | `/users?username={username}` | เข้าสู่ระบบ (เทียบรหัสผ่านในแอป) | `user_service.dart` |
| GET | `/users?role=tenant` | ตัวเลือกเลขห้องในฟอร์มออกบิล | `user_service.dart` |
| GET | `/bills` | หน้าบิลของผู้ดูแล | `bill_service.dart` |
| GET | `/bills?room={room}` | หน้าหลักและหน้าบิลของผู้เช่า / เช็กบิลซ้ำ | `bill_service.dart` |
| POST | `/bills` | ผู้ดูแลออกบิลใหม่ | `bill_service.dart` |
| PATCH | `/bills/{id}` | แจ้งชำระ `{ "status": "pending", "paymentRef": ... }` / ยืนยันรับเงิน / ตีกลับ | `bill_service.dart` |
| DELETE | `/bills/{id}` | ลบบิลที่ออกผิด | `bill_service.dart` |
| GET | `/repairs` และ `/repairs?room={room}` | งานซ่อมทุกห้อง / ของห้องตัวเอง | `repair_service.dart` |
| POST | `/repairs` | ผู้เช่าแจ้งซ่อมใหม่ | `repair_service.dart` |
| PATCH | `/repairs/{id}` | เปลี่ยนสถานะ `{ "status": "in_progress" }` | `repair_service.dart` |
| GET | `/announcements` | หน้าประกาศ / ประกาศล่าสุดในหน้าหลัก | `announcement_service.dart` |
| POST | `/announcements` | ลงประกาศใหม่ | `announcement_service.dart` |
| DELETE | `/announcements/{id}` | ลบประกาศ | `announcement_service.dart` |

> การเก็บรหัสผ่านเป็นข้อความธรรมดาใน `db.json` และเทียบรหัสในแอป เหมาะกับงานสาธิตในรายวิชาเท่านั้น
> ระบบจริงต้องให้ server เป็นคนตรวจรหัสผ่าน และเข้ารหัสรหัสผ่านก่อนเก็บ

### การจัดการ error

ทุก service ใช้ `try/catch` + `timeout` 10 วินาที + เช็ก `statusCode` แล้วแปลงเป็นข้อความภาษาไทย (`ApiException`) ทุกหน้าที่โหลดข้อมูลมีปุ่ม **ลองใหม่**
ถ้าปิด server จะขึ้น "เชื่อมต่อ server ไม่ได้ กรุณาเปิด server ก่อน" และอ่านผลด้วย `utf8.decode(response.bodyBytes)` เพื่อให้ภาษาไทยไม่เพี้ยน
บันทึกสำเร็จขึ้น SnackBar สีเขียว ผิดพลาดสีแดง และการลบ / เปลี่ยนสถานะ / ออกจากระบบต้องยืนยันผ่าน Dialog ก่อน

## ชุดข้อมูลใน server

| ชุดข้อมูล | จำนวนตัวอย่าง | หมายเหตุ |
| --- | --- | --- |
| `users` | 4 คน | ผู้ดูแล 1 คน, ผู้เช่า 3 คน (ห้อง A101, A102, B201) `{ username, password, name, role, room, phone }` |
| `bills` | 6 บิล | รอบ ต.ค. และ พ.ย. 2569 ครบทั้ง 3 สถานะ `unpaid` / `pending` / `paid` |
| `repairs` | 4 งาน | ครบทั้ง 3 สถานะ `pending` / `in_progress` / `done` มี `category`, `urgency`, `allowEnter` |
| `announcements` | 3 ประกาศ | มีประกาศสำคัญ (`isImportant: true`) 1 รายการ |

ข้อมูลตัวอย่างอยู่ใน `server/db.sample.json` ตอนเปิด server ครั้งแรกจะคัดลอกเป็น `db.json` ให้เอง
`reset_data.bat` (หรือ `npm run reset` ในโฟลเดอร์ `server`) คัดลอกทับเพื่อกลับเป็นข้อมูลเริ่มต้น

## โครงสร้างไฟล์

```
lib/
├── main.dart                     # MaterialApp, ธีม, named routes ('/', '/login', '/tenant', '/admin'), ภาษาไทย
├── constant/
│   ├── api_config.dart           # ที่อยู่ server (port 3000) และ timeout จุดเดียว
│   ├── app_constant.dart         # บทบาท สถานะบิล/งานซ่อม หมวดงานซ่อม ความเร่งด่วน ชื่อเดือนไทย
│   ├── app_format.dart           # จัดรูปแบบเงินและวันที่ (intl)
│   ├── color.dart                # สีของแอป
│   └── theme_data.dart           # ธีมสว่าง/มืด
├── model/                        # constructor + fromJson / toJson
│   ├── user_data.dart  bill_data.dart (ยอดรวม)  repair_data.dart  announcement_data.dart
├── service/                      # เรียก API ด้วย http
│   ├── api_client.dart           # http.Client ที่ใช้ร่วมกัน + ApiException
│   ├── user_service.dart  bill_service.dart  repair_service.dart  announcement_service.dart
│   └── pref_service.dart         # shared_preferences (ธีม + ผู้ใช้ที่ล็อกอิน)
├── screens/
│   ├── splash_screen.dart  login_screen.dart  profile_screen.dart  announcement_screen.dart
│   ├── tenant_main_screen.dart   # BottomNavigationBar 5 เมนู
│   ├── tenant_home_screen.dart  tenant_bill_screen.dart  bill_detail_screen.dart
│   ├── tenant_repair_screen.dart  repair_form_screen.dart
│   ├── admin_main_screen.dart    # BottomNavigationBar 4 เมนู
│   ├── admin_bill_screen.dart  bill_form_screen.dart  admin_repair_screen.dart
│   └── announcement_form_screen.dart
└── widgets/                      # custom widget ที่ใช้ซ้ำ
    ├── bill_card.dart  repair_card.dart  announcement_card.dart
    ├── summary_card.dart (AnimatedContainer)  repair_progress.dart (AnimatedContainer)
    ├── status_chip.dart  icon_box.dart  info_row.dart  app_logo.dart  section_title.dart
    └── app_snack_bar.dart  confirm_dialog.dart  error_view.dart  empty_view.dart
        loading_view.dart  primary_button.dart  scroll_message.dart
server/   db.sample.json, db.json, package.json (json-server 0.17.4)
test/     model_test, service_test, tenant_flow_test, admin_flow_test (MockClient จาก package:http/testing.dart)
```

## ตรวจคุณภาพ

```bat
flutter analyze
flutter test
```
