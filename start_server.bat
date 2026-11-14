@echo off
chcp 65001 >nul
title dorm_app server (json-server :3000)
rem ===== เปิด REST API ของแอปหอพัก (json-server) =====
rem ดับเบิลคลิกไฟล์นี้ได้เลย ปิดหน้าต่างนี้ = ปิด server

cd /d "%~dp0server"

where node >nul 2>nul
if errorlevel 1 (
  echo [ผิดพลาด] ไม่พบ Node.js กรุณาติดตั้งจาก https://nodejs.org แล้วเปิดไฟล์นี้ใหม่
  pause
  exit /b 1
)

if not exist "node_modules\json-server" (
  echo กำลังติดตั้ง package ของ server ครั้งแรก [npm install] ...
  call npm install --no-audit --no-fund
  if errorlevel 1 (
    echo [ผิดพลาด] ติดตั้ง package ไม่สำเร็จ ตรวจการเชื่อมต่ออินเทอร์เน็ตแล้วลองใหม่
    pause
    exit /b 1
  )
)

if not exist "db.json" (
  echo ยังไม่มี db.json จึงสร้างจากข้อมูลตัวอย่าง db.sample.json
  copy /y "db.sample.json" "db.json" >nul
)

echo.
echo เปิด server ที่ http://localhost:3000  [หน้าเว็บของแอป http://localhost:3000  ข้อมูล http://localhost:3000/users]
echo ปิด server: กด Ctrl+C หรือปิดหน้าต่างนี้
echo.
call npm start

echo.
echo server หยุดทำงานแล้ว (ถ้ามีข้อความ error ด้านบน เช่น port 3000 ถูกใช้อยู่ ดูวิธีแก้ใน HOW_TO_RUN.md)
pause
