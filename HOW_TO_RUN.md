# วิธีรันแอปหอพักอุ่นใจ (ทีละขั้น)

แอปนี้มี 2 ส่วนที่ต้องเปิดพร้อมกัน

1. **server** (โฟลเดอร์ `server/`): REST API จาก json-server เก็บข้อมูลในไฟล์ `server/db.json`
2. **แอป Flutter**: รันบน Android Emulator หรือ Chrome แล้วเรียก API จาก server

ต้อง **เปิด server ก่อนเสมอ** แล้วจึงรันแอป ไม่อย่างนั้นแอปจะขึ้นว่า "เชื่อมต่อ server ไม่ได้ กรุณาเปิด server ก่อน"

มี 3 วิธีให้เลือก

| วิธี | ใช้เมื่อ | ต้องติดตั้ง |
| --- | --- | --- |
| **`run_web.bat`** (แนะนำ เบาที่สุด) | เครื่องไม่แรง เปิด emulator ไม่ไหว อยากเปิดแอปดูหรือเดโมเลย | Node.js + Chrome (ไม่ต้องมี Flutter / Android Studio) |
| **`run_apk.bat`** | อยากเห็นบน Android Emulator แต่ไม่ได้จะแก้โค้ด หรือเครื่อง build Android ไม่ผ่าน | Node.js + Android Studio (ไม่ต้องมี Flutter) |
| **`run_all.bat`** | จะแก้โค้ดแล้วรันใหม่ หรือใช้ hot reload | Flutter + Node.js + Android Studio |

## วิธีที่ 0: เปิดแอปใน Chrome (`run_web.bat`) ไม่ต้องใช้ emulator

ใช้แอปเวอร์ชันเว็บที่ build ไว้แล้วในโฟลเดอร์ `dist/web` **ไม่ต้อง build เอง และไม่ต้องเปิด emulator** จึงกินเครื่องน้อยที่สุด
server ตัวเดิม (port 3000) เปิดทั้งหน้าเว็บของแอปและ REST API ให้พร้อมกัน จึงไม่ติดปัญหา CORS

### ติดตั้งโปรแกรม (ทำครั้งเดียว)

1. **Node.js** รุ่น LTS จาก https://nodejs.org (กด Next ไปจนจบ)
2. **Google Chrome** จาก https://www.google.com/chrome (ถ้าไม่มี สคริปต์จะเปิดด้วยเบราว์เซอร์หลักของเครื่องแทน)
3. เปิด Command Prompt **หน้าต่างใหม่** แล้วเช็กว่าติดตั้ง Node.js แล้ว

   ```bat
   node --version
   ```

### เปิดแอป

1. ดับเบิลคลิก **`run_web.bat`** ในโฟลเดอร์โปรเจกต์
2. รอจนสคริปต์ทำครบ 2 ขั้น (ครั้งแรกประมาณ 1 นาที เพราะต้องติดตั้ง package ของ server ผ่านอินเทอร์เน็ต)

   ```
   [1/2] ตรวจ server ...              -> เปิดหน้าต่าง "dorm_app server" ให้เอง ห้ามปิดหน้าต่างนั้น
   [2/2] เปิดแอปในเบราว์เซอร์ ...     -> เปิด Chrome ที่ http://localhost:3000 ให้เอง
   ```

3. เข้าสู่ระบบด้วย[บัญชีทดสอบ](#ขั้นที่-4-เข้าสู่ระบบด้วยบัญชีทดสอบ) เช่น `admin` / `admin1234` หรือ `somchai` / `1234`
4. อยากให้หน้าจอเป็นขนาดมือถือ: กด **F12** แล้วกด **Ctrl+Shift+M** จากนั้นเลือกรุ่นมือถือที่แถบด้านบน (เช่น Pixel 7 หรือ iPhone 12 Pro)
5. ครั้งต่อไปดับเบิลคลิก `run_web.bat` ซ้ำ หรือเปิด `start_server.bat` แล้วเข้า http://localhost:3000 เองก็ได้

### ปิดทุกอย่าง

ปิดหน้าต่าง **"dorm_app server"** = ปิด server แล้วปิดแท็บ Chrome
ข้อมูลที่เพิ่มหรือแก้ในแอปเก็บอยู่ใน `server/db.json` ถ้าอยากล้างกลับเป็นข้อมูลตัวอย่าง ดับเบิลคลิก `reset_data.bat`

### ถ้าเจอปัญหา

| ข้อความ | วิธีแก้ |
| --- | --- |
| `[ผิดพลาด] ไม่พบ Node.js` | ติดตั้ง Node.js แล้ว **เปิดไฟล์ใหม่** (ถ้ายังไม่หายให้รีสตาร์ตเครื่อง) |
| `[ผิดพลาด] ไม่พบไฟล์ dist\web\index.html` | `git pull` ใหม่ หรือดาวน์โหลด repo ใหม่ทั้งโฟลเดอร์ |
| `[ผิดพลาด] server ที่เปิดอยู่ตอนนี้เป็นตัวเก่า...` | ปิดหน้าต่าง "dorm_app server" ที่เปิดค้างไว้ แล้วดับเบิลคลิก `run_web.bat` ใหม่ |
| `[ผิดพลาด] port 3000 ถูกโปรแกรมอื่นใช้อยู่` | ปิดโปรแกรมอื่นที่ใช้ port 3000 ก่อน ดู[หัวข้อ port 3000](#port-3000-ถูกใช้อยู่-server-เปิดไม่ขึ้น-มีคำว่า-eaddrinuse) |
| Chrome ขึ้นหน้าขาวนาน ๆ | รอสักครู่ (ครั้งแรกโหลดประมาณ 5-10 วินาที) ถ้ายังขาวให้กด **Ctrl+F5** |
| แอปขึ้นว่า "เชื่อมต่อ server ไม่ได้" | ดูว่าหน้าต่าง server ยังเปิดอยู่ ถ้าไม่ ดับเบิลคลิก `run_web.bat` ใหม่ แล้วกด **ลองใหม่** ในแอป |

> ถ้าแก้โค้ด ต้อง build เวอร์ชันเว็บใหม่ด้วยคำสั่ง `flutter build web --release --no-web-resources-cdn`
> แล้วคัดลอกทุกอย่างใน `build\web` ไปทับ `dist\web` จากนั้นกด Ctrl+F5 ใน Chrome
> (`--no-web-resources-cdn` ทำให้แอปไม่ต้องโหลดไฟล์ของ Flutter จากอินเทอร์เน็ต)

---

## วิธีที่ 1: เปิดแอปจากไฟล์ APK สำเร็จรูป (`run_apk.bat`)

ใช้ไฟล์ `dist/DormApp.apk` ที่ build ไว้แล้ว **เครื่องที่ใช้ไม่ต้อง build เอง** จึงไม่มีปัญหาเรื่องเวอร์ชัน Flutter / Gradle / Java

### ติดตั้งโปรแกรม (ทำครั้งเดียว)

1. **Node.js** รุ่น LTS จาก https://nodejs.org (กด Next ไปจนจบ)
2. **Android Studio** จาก https://developer.android.com/studio
   - เปิดครั้งแรกให้เลือก Standard แล้วรอโหลด Android SDK จนเสร็จ
3. **สร้าง emulator** (ถ้ายังไม่มี) ใน Android Studio > More Actions (หรือเมนู Tools) > **Device Manager** > ปุ่ม **+** > Create Virtual Device
   - เลือกเครื่อง เช่น Pixel 8 > Next > เลือก system image ที่มีคำว่า **x86_64** (กดลูกศรดาวน์โหลดถ้ายังไม่มี) > Next > Finish
4. เปิด Command Prompt **หน้าต่างใหม่** แล้วเช็กว่าติดตั้ง Node.js แล้ว

   ```bat
   node --version
   ```

### เปิดแอป

1. ดับเบิลคลิก **`run_apk.bat`** ในโฟลเดอร์โปรเจกต์
2. รอจนสคริปต์ทำครบ 3 ขั้น (ครั้งแรกประมาณ 2-4 นาที เพราะต้องติดตั้ง package ของ server และ boot emulator)

   ```
   [1/3] ตรวจ server ...            -> เปิดหน้าต่าง "dorm_app server" ให้เอง ห้ามปิดหน้าต่างนั้น
   [2/3] ตรวจ Android Emulator ...  -> เปิด emulator ให้เอง แล้วรอจน boot เสร็จ
   [3/3] ติดตั้งแอปจากไฟล์ ...       -> ขึ้น Success แล้วแอปจะเปิดขึ้นบน emulator เอง
   ```

3. เมื่อขึ้นข้อความ `เปิดแอปหอพักอุ่นใจบน emulator แล้ว` ก็ใช้แอปบน emulator ได้เลย
   เข้าสู่ระบบด้วย[บัญชีทดสอบ](#ขั้นที่-4-เข้าสู่ระบบด้วยบัญชีทดสอบ) เช่น `admin` / `admin1234` หรือ `somchai` / `1234`
   หน้าต่าง `run_apk.bat` กดปุ่มใดก็ได้เพื่อปิดได้ แอปยังเปิดอยู่
4. ครั้งต่อไปจะเปิดแอปจากไอคอน **หอพักอุ่นใจ** ในหน้ารวมแอปของ emulator ก็ได้ แต่ต้องเปิด server ก่อน (ดับเบิลคลิก `start_server.bat`)
   หรือดับเบิลคลิก `run_apk.bat` ซ้ำ ซึ่งจะเปิดให้ครบทุกอย่างอีกครั้ง

### ปิดทุกอย่าง

1. ปิดหน้าต่าง **"dorm_app server"** (หรือหน้าต่าง cmd ที่ขึ้นว่า `npm start` / `Watching...`) = ปิด server
2. กด X ที่หน้าต่าง emulator = ปิด emulator

ข้อมูลที่เพิ่มหรือแก้ในแอปเก็บอยู่ใน `server/db.json` ถ้าอยากล้างกลับเป็นข้อมูลตัวอย่าง ดับเบิลคลิก `reset_data.bat`

### ถ้าเจอปัญหา

| ข้อความ | วิธีแก้ |
| --- | --- |
| `[ผิดพลาด] ไม่พบ Node.js` | ติดตั้ง Node.js แล้ว **เปิดไฟล์ใหม่** (ถ้ายังไม่หายให้รีสตาร์ตเครื่อง) |
| `[ผิดพลาด] ไม่พบ Android SDK` | เปิด Android Studio ให้โหลด SDK จนเสร็จก่อน ถ้าติดตั้ง SDK ไว้ที่อื่น ให้ตั้ง `ANDROID_HOME` ชี้ไปที่โฟลเดอร์นั้น |
| `[ผิดพลาด] ยังไม่มี emulator ในเครื่อง` | สร้าง emulator ตามข้อ 3 ด้านบน |
| `[ผิดพลาด] port 3000 ถูกโปรแกรมอื่นใช้อยู่` | ปิดโปรแกรมอื่นที่ใช้ port 3000 ก่อน ดู[หัวข้อ port 3000](#port-3000-ถูกใช้อยู่-server-เปิดไม่ขึ้น-มีคำว่า-eaddrinuse) |
| `[ผิดพลาด] emulator boot ไม่เสร็จภายใน 3 นาที` | เปิด emulator จาก Device Manager เองให้ขึ้นหน้า Home ก่อน แล้วดับเบิลคลิก `run_apk.bat` ใหม่ ถ้าค้างให้กด ▼ ข้างปุ่ม ▶ > **Cold Boot Now** |
| `INSTALL_FAILED_...` | สคริปต์จะลบแอปเดิมแล้วติดตั้งใหม่ให้เองถ้าลายเซ็นไม่ตรง ถ้ายังไม่ผ่าน ให้ลบแอปหอพักอุ่นใจใน emulator เอง (กดค้างที่ไอคอน > Uninstall) แล้วลองใหม่ |
| แอปขึ้นว่า "เชื่อมต่อ server ไม่ได้" | ดูว่าหน้าต่าง server ยังเปิดอยู่ ถ้าไม่ ดับเบิลคลิก `start_server.bat` แล้วกด **ลองใหม่** ในแอป |

> ไฟล์ APK นี้ใช้ได้กับ **Android Emulator** เท่านั้น เพราะแอปเรียก server ที่ `10.0.2.2:3000` ซึ่งเป็นที่อยู่ของคอมพิวเตอร์เมื่อมองจาก emulator
> ถ้าแก้โค้ด ต้อง build APK ใหม่ด้วยคำสั่ง `flutter build apk --release` แล้วคัดลอก `build\app\outputs\flutter-apk\app-release.apk` ไปทับ `dist\DormApp.apk`

---

## วิธีที่ 2: ทางลัดสำหรับนักพัฒนา ดับเบิลคลิก `run_all.bat` ครั้งเดียว

ถ้าติดตั้งโปรแกรมใน [ขั้นที่ 1](#ขั้นที่-1-ติดตั้งโปรแกรม-ทำครั้งเดียว) ครบแล้ว และมี Android Emulator อย่างน้อย 1 เครื่อง
ดับเบิลคลิก **`run_all.bat`** ไฟล์เดียวจะทำให้ครบทั้ง 3 อย่าง

1. เปิด server ในหน้าต่างใหม่ชื่อ "dorm_app server" (ถ้าเปิดอยู่แล้วจะข้าม)
2. เปิด emulator เครื่องแรกที่มีในเครื่อง แล้วรอจน boot เสร็จ (ถ้าเปิดอยู่แล้วจะข้าม)
3. รัน `flutter pub get` และ `flutter run -d emulator` จนแอปขึ้นบน emulator

ครั้งแรกรวมแล้วใช้เวลาประมาณ 3-7 นาที (ส่วนใหญ่คือ build Android) ครั้งต่อไปเร็วขึ้นมาก

- จะมี **2 หน้าต่าง**: หน้าต่าง `run_all.bat` (แอป) และหน้าต่าง "dorm_app server" อย่าปิดหน้าต่าง server ระหว่างใช้แอป
- ปิดแอป: กด `q` ในหน้าต่าง `run_all.bat` ส่วน server และ emulator ยังเปิดอยู่ กด `run_all.bat` ซ้ำได้เลย
- เลิกใช้งาน: ปิดหน้าต่าง "dorm_app server" และปิด emulator

ถ้าอยากรันบน Chrome หรือทำทีละขั้นเอง ทำตามขั้นที่ 2-3 ด้านล่าง

---

## ขั้นที่ 1 ติดตั้งโปรแกรม (ทำครั้งเดียว)

| โปรแกรม | ใช้ทำอะไร | ดาวน์โหลด |
| --- | --- | --- |
| Flutter SDK 3.32 ขึ้นไป | รันแอป | https://docs.flutter.dev/get-started/install/windows |
| Node.js 18 ขึ้นไป (แนะนำรุ่น LTS) | รัน server (มี npm มาด้วย) | https://nodejs.org |
| Android Studio | มี Android SDK และ Android Emulator | https://developer.android.com/studio |
| Google Chrome | ถ้าจะรันแอปบนเว็บ | https://www.google.com/chrome |
| VS Code + ส่วนเสริม Flutter (ไม่บังคับ) | เปิดโค้ดและกด F5 เพื่อรัน | https://code.visualstudio.com |

ติดตั้งเสร็จแล้ว เปิด Command Prompt หรือ PowerShell **หน้าต่างใหม่** แล้วเช็กเวอร์ชัน

```bat
flutter --version
node --version
npm --version
flutter doctor
```

ตัวอย่างผลบนเครื่องที่ใช้ทดสอบ: Flutter 3.32.7, Node v22.20.0
ใน `flutter doctor` ให้ดูว่าบรรทัด **Flutter**, **Android toolchain** และ **Chrome** ขึ้นเครื่องหมายถูก
(ถ้าบอกว่า Android licenses ยังไม่ยอมรับ ให้รัน `flutter doctor --android-licenses` แล้วตอบ `y`)

---

## ขั้นที่ 2 เปิด server

### วิธีที่ง่ายที่สุด

ดับเบิลคลิกไฟล์ **`start_server.bat`** ในโฟลเดอร์โปรเจกต์

- ครั้งแรกจะติดตั้ง package ให้เอง (`npm install` ใช้เวลาประมาณ 10-30 วินาที ต้องต่ออินเทอร์เน็ต)
- ถ้ายังไม่มี `server/db.json` จะสร้างจากข้อมูลตัวอย่างให้
- **ทิ้งหน้าต่างนี้เปิดไว้ตลอดที่ใช้แอป** ปิดหน้าต่าง = ปิด server

### หรือพิมพ์คำสั่งเอง

```bat
cd server
npm install
npm start
```

### รู้ได้อย่างไรว่าเปิดสำเร็จ

1. ในหน้าต่าง server จะมีข้อความ

   ```
   \{^_^}/ hi!
   Loading db.json
   Done
   Resources
   http://127.0.0.1:3000/users
   ...
   Watching...
   ```

2. เปิดเบราว์เซอร์ไปที่ **http://localhost:3000/users** ต้องเห็นข้อมูลผู้ใช้เป็น JSON
   (ลอง http://localhost:3000/bills, http://localhost:3000/repairs, http://localhost:3000/announcements ได้เช่นกัน)

ทุกครั้งที่แอปเรียก API หน้าต่าง server จะแสดงบรรทัด เช่น `GET /bills?room=A101 200` หรือ `PATCH /bills/4 200`
ใช้ดูได้ว่าแอปเรียก method อะไร

---

## ขั้นที่ 3 รันแอป

เปิด Command Prompt **หน้าต่างใหม่** (หน้าต่าง server ต้องเปิดค้างไว้) แล้วเข้าโฟลเดอร์โปรเจกต์
(โฟลเดอร์ที่มีไฟล์ `pubspec.yaml` เช่น `cd C:\work\dorm_app`)

```bat
flutter pub get
```

### แบบที่ 1: Android Emulator

1. เปิด emulator ด้วยวิธีใดวิธีหนึ่ง
   - Android Studio > **Device Manager** > กดปุ่ม ▶ ที่เครื่องที่ต้องการ
   - หรือใช้คำสั่ง

     ```bat
     flutter emulators
     flutter emulators --launch flutter_emulator
     ```

     (`flutter_emulator` คือชื่อเครื่องบนเครื่องที่ใช้ทดสอบ ให้เปลี่ยนเป็นชื่อที่ `flutter emulators` แสดง)
2. รอจนเห็นหน้า Home ของ Android แล้วเช็กว่า Flutter มองเห็น

   ```bat
   flutter devices
   ```

   ต้องมีบรรทัดที่ขึ้นต้นด้วย `sdk gphone ... • emulator-5554`
3. รันแอป

   ```bat
   flutter run -d emulator
   ```

   ครั้งแรกจะ build นาน 2-5 นาที ครั้งต่อไปเร็วขึ้นมาก

### แบบที่ 2: Chrome

```bat
flutter run -d chrome
```

Flutter จะเปิดหน้าต่าง Chrome ใหม่ให้เอง (ครั้งแรกใช้เวลาประมาณ 30 วินาที)

### แบบที่ 3: กด F5 ใน VS Code

1. เปิดโฟลเดอร์โปรเจกต์ (ที่มี `pubspec.yaml`) ใน VS Code
2. ไปที่แถบ **Run and Debug** (Ctrl+Shift+D) เลือกจากรายการด้านบน
   - **แอปหอพัก: Android Emulator** (ต้องเปิด emulator ไว้ก่อน)
   - **แอปหอพัก: Chrome**
3. กด **F5**

---

## ขั้นที่ 4 เข้าสู่ระบบด้วยบัญชีทดสอบ

| บทบาท | ชื่อผู้ใช้ | รหัสผ่าน | ห้อง | ข้อมูลที่เตรียมไว้ |
| --- | --- | --- | --- | --- |
| ผู้ดูแล | `admin` | `admin1234` | - | เห็นบิลและงานซ่อมทุกห้อง |
| ผู้เช่า | `somchai` | `1234` | A101 | ค้างชำระ 1 บิล, งานซ่อม 2 รายการ |
| ผู้เช่า | `malee` | `1234` | A102 | แจ้งชำระแล้วรอตรวจสอบ 1 บิล |
| ผู้เช่า | `wichai` | `1234` | B201 | ค้างชำระ 2 บิล |

### ลำดับเดโมที่แนะนำ

1. เข้า `somchai` > เมนูบิล > เปิดบิลที่ค้างชำระ > กรอกเลขอ้างอิง (อย่างน้อย 6 ตัว) > แจ้งชำระ (PATCH)
2. เมนูแจ้งซ่อม > แจ้งซ่อมใหม่ > เลือกหมวดหมู่ ความเร่งด่วน กรอกรายละเอียด > ส่ง (POST)
3. โปรไฟล์ > ลองสลับโหมดมืด > ออกจากระบบ
4. เข้า `admin` > เมนูบิล > ตัวกรอง "รอตรวจสอบ" > ตรวจสอบการชำระ > ยืนยันรับชำระ หรือ ไม่พบยอดโอน
5. ปุ่ม "ออกบิล" > เลือกห้อง เดือน กรอกค่าเช่า/น้ำ/ไฟ > ออกบิล (POST)
6. เมนูงานซ่อม > รับงาน > ปิดงาน (PATCH)
7. เมนูประกาศ > ลงประกาศ (POST) > ลบประกาศ (DELETE)
8. กลับไปเข้า `somchai` แล้วดึงหน้าจอลงในเมนูแจ้งซ่อม จะเห็นสถานะที่ผู้ดูแลเปลี่ยน

ทุกครั้งที่บันทึก เปิดไฟล์ `server/db.json` ดูได้ว่าข้อมูลถูกเขียนลงไฟล์จริง

---

## ขั้นที่ 5 รีเซ็ตข้อมูลกลับเป็นค่าเริ่มต้นหลังเดโม

ดับเบิลคลิก **`reset_data.bat`** แล้วกดปุ่มใดก็ได้เพื่อยืนยัน
(หรือรัน `npm run reset` ในโฟลเดอร์ `server`)

- ไฟล์ `server/db.sample.json` จะถูกคัดลอกทับ `server/db.json`
- ถ้า server เปิดอยู่ ไม่ต้องปิดเปิดใหม่ server จะโหลดไฟล์ใหม่เอง
- ในแอปให้ดึงหน้าจอลงเพื่อโหลดใหม่ หรือออกจากระบบแล้วเข้าใหม่

---

## แก้ปัญหาที่เจอบ่อย

### แอปขึ้นว่า "เชื่อมต่อ server ไม่ได้ กรุณาเปิด server ก่อน"

1. ดูว่าหน้าต่าง server ยังเปิดอยู่และมีคำว่า `Watching...` ถ้าไม่มี ให้ดับเบิลคลิก `start_server.bat` ใหม่
2. เปิด http://localhost:3000/users ในเบราว์เซอร์ ถ้าไม่ขึ้น JSON แปลว่า server ไม่ได้เปิด
3. เปิด server แล้วกดปุ่ม **ลองใหม่** ในแอป หรือดึงหน้าจอลง
4. บน Android Emulator ข้อความนี้อาจใช้เวลาประมาณ 10 วินาทีกว่าจะขึ้น (แอปรอ server ตามเวลาที่ตั้งไว้ใน `lib/constant/api_config.dart`)

### port 3000 ถูกใช้อยู่ (server เปิดไม่ขึ้น มีคำว่า `EADDRINUSE`)

มักเกิดจากเปิด server ซ้ำ 2 หน้าต่าง หรือมีโปรแกรมอื่นใช้ port 3000

1. ปิดหน้าต่าง server อื่นที่เปิดค้างไว้ แล้วลองใหม่
2. ถ้ายังไม่หาย หาโปรแกรมที่ใช้ port 3000 แล้วปิด

   ```bat
   netstat -ano | findstr :3000
   taskkill /PID <เลข PID ตัวสุดท้ายของบรรทัด LISTENING> /F
   ```

3. หรือเปลี่ยน port ทั้ง 2 จุดให้ตรงกัน
   - `server/package.json` ในคำสั่ง `start` ตรง `--port 3000`
   - `lib/constant/api_config.dart` ตรง `const int serverPort = 3000;`

### บน Chrome ขึ้น error เรื่อง CORS

json-server 0.17.4 ที่ล็อกไว้ใน `server/package.json` เปิด CORS ให้อยู่แล้ว (ทดสอบแล้วว่า GET, POST, PATCH, DELETE ใช้ได้จาก Chrome)
ถ้ายังเจอ ให้ตรวจว่า

1. เปิด server ด้วย `start_server.bat` หรือ `npm start` ในโฟลเดอร์ `server` ไม่ใช่ json-server รุ่นอื่นที่ติดตั้งไว้ทั้งเครื่อง (`npm i -g`)
2. เปิดแอปด้วย `flutter run -d chrome` ไม่ใช่ดับเบิลคลิกไฟล์ html ในโฟลเดอร์ `build`
3. กด F12 ในหน้าต่าง Chrome > แท็บ Console ดูข้อความ error เต็ม

### Emulator เรียก localhost ไม่ได้

ใน Android Emulator คำว่า `localhost` หมายถึงตัว emulator เอง ไม่ใช่คอมพิวเตอร์ของเรา
แอปนี้จัดการให้แล้ว: เมื่อรันบน Android จะเรียก `http://10.0.2.2:3000` ซึ่งเป็นที่อยู่ของคอมพิวเตอร์เมื่อมองจาก emulator
(ตั้งไว้ใน `lib/constant/api_config.dart`) และอนุญาตให้เรียก http แบบไม่เข้ารหัสไปที่ `10.0.2.2` ไว้ใน
`android/app/src/main/res/xml/network_security_config.xml`

ถ้ายังต่อไม่ได้ ให้ลองเปิด `http://10.0.2.2:3000/users` ใน Chrome **ภายใน emulator** ถ้าเปิดไม่ได้แปลว่า server ไม่ได้เปิดอยู่บนคอมพิวเตอร์

> แอปนี้ตั้งให้ใช้กับ emulator และ Chrome ในเครื่องเดียวกับ server เท่านั้น ถ้าจะใช้มือถือจริงต้องเปลี่ยนที่อยู่ server เป็น IP ของคอมพิวเตอร์ และให้ server รับการเชื่อมต่อจากเครือข่าย ซึ่งไม่ได้ตั้งไว้

### `'npm' is not recognized` หรือ `'flutter' is not recognized`

ยังไม่ได้ติดตั้ง หรือติดตั้งแล้วแต่ยังไม่ได้เปิดหน้าต่าง Command Prompt ใหม่ ให้ปิดแล้วเปิดใหม่ (หรือรีสตาร์ตเครื่อง)

### PowerShell ขึ้นว่า `running scripts is disabled on this system` ตอนพิมพ์ npm

ใช้ Command Prompt (cmd) แทน PowerShell หรือดับเบิลคลิก `start_server.bat`

### `flutter run -d emulator` ขึ้นว่าไม่พบอุปกรณ์

emulator ยังเปิดไม่เสร็จ รอจนเห็นหน้า Home ของ Android แล้วรัน `flutter devices` เช็กอีกครั้ง

### `run_all.bat` ขึ้น "[ผิดพลาด] ..."

อ่านข้อความในหน้าต่างนั้น จะบอกว่าขาดอะไร เช่น ไม่พบ flutter, ไม่พบ Node.js, ไม่พบ Android SDK,
ยังไม่มี emulator (สร้างได้ที่ Android Studio > Device Manager > Create Virtual Device)
หรือ server เปิดไม่สำเร็จ (ดูข้อความในหน้าต่าง "dorm_app server" เช่น port 3000 ถูกใช้อยู่)

### build Android ขึ้นคำเตือนเรื่อง Android NDK

ข้อความ `Your project is configured with Android NDK ... shared_preferences_android requires Android NDK ...` เป็นแค่คำเตือน
ถ้าตามด้วย `√ Built build\app\outputs\flutter-apk\app-debug.apk` แปลว่า build สำเร็จ ไม่ต้องแก้อะไร

### build Android ครั้งแรกล้มเพราะ Gradle

ลองปิด Gradle ที่ค้างอยู่แล้ว build ใหม่

```bat
cd android
gradlew --stop
cd ..
flutter clean
flutter pub get
flutter run -d emulator
```

ถ้าเครื่อง build ไม่ผ่านจริง ๆ (เช่น Flutter / Java คนละเวอร์ชัน) ให้ใช้ [วิธีที่ 1: `run_apk.bat`](#วิธีที่-1-เปิดแอปจากไฟล์-apk-สำเร็จรูป-run_apkbat) แทน ไม่ต้อง build เอง
โปรเจกต์นี้ตั้ง Gradle ไว้ที่ **8.14.3** (`android/gradle/wrapper/gradle-wrapper.properties`) และ Android Gradle Plugin ที่ **8.11.1** (`android/settings.gradle.kts`) ทดสอบ build ผ่านบน Flutter 3.32.7 + Java 23
