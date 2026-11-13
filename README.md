# หอพักอุ่นใจ (dorm_app)

## 1. โปรแกรมที่ต้องติดตั้งก่อน

| โปรแกรม | เวอร์ชัน | ดาวน์โหลด |
| --- | --- | --- |
| Flutter SDK | 3.32 ขึ้นไป | https://docs.flutter.dev/get-started/install/windows |
| Node.js | 18 ขึ้นไป (แนะนำรุ่น LTS) | https://nodejs.org |
| Android Studio | พร้อม Android Emulator อย่างน้อย 1 เครื่อง | https://developer.android.com/studio |

ติดตั้งเสร็จแล้วเปิด Command Prompt หน้าต่างใหม่ เช็กว่าใช้ได้

```bat
flutter --version
node --version
flutter doctor
```

ใน `flutter doctor` บรรทัด **Flutter** และ **Android toolchain** ต้องขึ้นเครื่องหมายถูก
(ถ้าบอกว่า Android licenses ยังไม่ยอมรับ ให้รัน `flutter doctor --android-licenses` แล้วตอบ `y`)

ยังไม่มี emulator: เปิด Android Studio > **Device Manager** > **Create Virtual Device** แล้วสร้างเครื่องใหม่ 1 เครื่อง

## 2. วิธีรัน

**ดับเบิลคลิกไฟล์ `run_all.bat`** ในโฟลเดอร์โปรเจกต์ ไฟล์เดียวจบ

ไฟล์นี้จะทำให้เองตามลำดับ

1. เปิด server ในหน้าต่างใหม่ชื่อ "dorm_app server"
2. เปิด Android Emulator แล้วรอจนพร้อม
3. รันแอปขึ้นบน emulator

ครั้งแรกใช้เวลาประมาณ 3-7 นาที (ต้องต่ออินเทอร์เน็ต) ครั้งต่อไปเร็วขึ้นมาก

ระหว่างใช้งาน

- **อย่าปิดหน้าต่าง "dorm_app server"** ปิดเมื่อไหร่แอปจะใช้งานไม่ได้
- ปิดแอป: กด `q` ในหน้าต่าง `run_all.bat`
- เลิกใช้งาน: ปิดหน้าต่าง "dorm_app server" และปิด emulator

เข้าสู่ระบบด้วยบัญชีทดสอบ

| บทบาท | ชื่อผู้ใช้ | รหัสผ่าน |
| --- | --- | --- |
| ผู้ดูแล | `admin` | `admin1234` |
| ผู้เช่า | `somchai` | `1234` |
| ผู้เช่า | `malee` | `1234` |
| ผู้เช่า | `wichai` | `1234` |

อยากล้างข้อมูลกลับเป็นค่าเริ่มต้นหลังทดลองใช้: ดับเบิลคลิก **`reset_data.bat`**

วิธีรันแบบอื่น (Chrome, VS Code) และวิธีแก้ปัญหา ดูที่ [HOW_TO_RUN.md](HOW_TO_RUN.md)
