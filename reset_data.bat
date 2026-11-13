@echo off
chcp 65001 >nul
rem ===== รีเซ็ตข้อมูลของ server กลับเป็นข้อมูลตัวอย่าง =====
rem คัดลอก server\db.sample.json ทับ server\db.json

cd /d "%~dp0server"

echo ข้อมูลทั้งหมดที่เพิ่มหรือแก้ระหว่างเดโม (บิล งานซ่อม ประกาศ) จะถูกแทนที่ด้วยข้อมูลตัวอย่าง
echo กดปุ่มใดก็ได้เพื่อรีเซ็ต หรือปิดหน้าต่างนี้เพื่อยกเลิก
pause >nul

copy /y "db.sample.json" "db.json" >nul
if errorlevel 1 (
  echo [ผิดพลาด] รีเซ็ตไม่สำเร็จ
  pause
  exit /b 1
)

echo รีเซ็ตข้อมูลเรียบร้อย
echo - ถ้า server เปิดอยู่ server จะโหลดข้อมูลใหม่เอง ไม่ต้องปิดเปิดใหม่
echo - ในแอปให้ดึงหน้าจอลงเพื่อโหลดใหม่ หรือออกจากระบบแล้วเข้าใหม่
pause
