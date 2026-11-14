@echo off
chcp 65001 >nul
title dorm_app - run web
rem ===== ดับเบิลคลิกครั้งเดียว: เปิด server + เปิดแอปใน Chrome (ไม่ต้องใช้ emulator) =====
rem ใช้แอปเวอร์ชันเว็บที่ build ไว้แล้วในโฟลเดอร์ dist\web จึงไม่ต้องมี Flutter / Android Studio ในเครื่อง
rem ต้องมีแค่ Node.js (สำหรับ server) และเบราว์เซอร์ (แนะนำ Google Chrome)
rem 1) เปิด server ในหน้าต่างแยก (ถ้ายังไม่ได้เปิด) server ตัวนี้เปิดหน้าเว็บของแอปให้ด้วย
rem 2) เปิด http://localhost:3000 ใน Chrome

cd /d "%~dp0"
set "PORT=3000"
set "URL=http://localhost:%PORT%"
if not exist "%~dp0dist\web\index.html" goto no_web

rem ---------- ตรวจโปรแกรมที่ต้องใช้ ----------
where node >nul 2>nul
if errorlevel 1 goto no_node

rem ---------- 1) server ----------
echo [1/2] ตรวจ server ...
call :check_server
if "%CODE%"=="200" goto server_ok
rem port ตอบกลับ แต่ไม่มี /users = เป็นโปรแกรมอื่น ไม่ใช่ server ของแอปนี้
if not "%CODE%"=="000" goto port_busy
echo       ยังไม่ได้เปิด กำลังเปิด server ในหน้าต่างใหม่ [ห้ามปิดหน้าต่างนั้น]
echo       ครั้งแรกต้องต่ออินเทอร์เน็ต เพื่อติดตั้ง package ของ server
start "dorm_app server" cmd /c call "%~dp0start_server.bat"
set /a TRIES=0
:wait_server
call :check_server
if "%CODE%"=="200" goto server_ok
set /a TRIES+=1
if %TRIES% geq 120 goto server_fail
ping -n 2 127.0.0.1 >nul
goto wait_server
:server_ok
echo       server พร้อมที่ %URL%

rem ---------- server เก่าที่เปิดค้างไว้ก่อนอัปเดต จะยังไม่เปิดหน้าเว็บ ----------
set "WCODE=000"
for /f %%c in ('curl.exe -s -o nul -m 3 -w "%%{http_code}" %URL%/flutter_bootstrap.js 2^>nul') do set "WCODE=%%c"
if not "%WCODE%"=="200" goto old_server

rem ---------- 2) เปิด Chrome ----------
echo [2/2] เปิดแอปในเบราว์เซอร์ ...
set "CHROME="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined CHROME if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "CHROME=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if defined CHROME (
  start "" "%CHROME%" "%URL%"
) else (
  echo       ไม่พบ Google Chrome จึงเปิดด้วยเบราว์เซอร์หลักของเครื่องแทน
  start "" "%URL%"
)
echo.
echo เปิดแอปหอพักอุ่นใจใน Chrome แล้ว ที่ %URL%
echo - ห้ามปิดหน้าต่าง "dorm_app server" ระหว่างใช้แอป
echo - ถ้าหน้าต่าง Chrome ถูกปิดไป เปิด %URL% ใหม่ได้เลย
echo - อยากให้หน้าตาเหมือนมือถือ: กด F12 แล้วกด Ctrl+Shift+M เพื่อเลือกขนาดจอมือถือ
echo - เลิกใช้: ปิดหน้าต่าง "dorm_app server" และปิดแท็บ Chrome
pause
exit /b 0

rem ---------- ฟังก์ชันตรวจ server: CODE = 200 (server ของแอปนี้), 000 (ยังไม่มีใครใช้ port), อื่น ๆ (โปรแกรมอื่น) ----------
:check_server
set "CODE=000"
for /f %%c in ('curl.exe -s -o nul -m 3 -w "%%{http_code}" http://127.0.0.1:%PORT%/users 2^>nul') do set "CODE=%%c"
exit /b 0

rem ---------- ข้อความผิดพลาด ----------
:no_node
echo [ผิดพลาด] ไม่พบ Node.js กรุณาติดตั้งจาก https://nodejs.org แล้วเปิดไฟล์นี้ใหม่
pause
exit /b 1
:no_web
echo [ผิดพลาด] ไม่พบไฟล์ dist\web\index.html
echo ไฟล์นี้อยู่ใน repo แล้ว ลอง git pull ใหม่ หรือดาวน์โหลด repo ใหม่ทั้งโฟลเดอร์
pause
exit /b 1
:old_server
echo [ผิดพลาด] server ที่เปิดอยู่ตอนนี้เป็นตัวเก่าที่ยังไม่เปิดหน้าเว็บของแอป
echo ปิดหน้าต่าง "dorm_app server" (หรือหน้าต่าง cmd ที่ขึ้นว่า npm start) แล้วดับเบิลคลิกไฟล์นี้ใหม่
pause
exit /b 1
:port_busy
echo [ผิดพลาด] port %PORT% ถูกโปรแกรมอื่นใช้อยู่ (ตอบกลับรหัส %CODE% ไม่ใช่ server ของแอปนี้)
echo กรุณาปิดหน้าต่าง server ของแอปอื่นที่ใช้ port %PORT% แล้วดับเบิลคลิกไฟล์นี้ใหม่
echo ดูโปรแกรมที่ใช้ port ได้ด้วยคำสั่ง: netstat -ano ^| findstr :%PORT%
pause
exit /b 1
:server_fail
echo [ผิดพลาด] เปิด server ไม่สำเร็จภายใน 2 นาที ดูข้อความในหน้าต่าง "dorm_app server"
pause
exit /b 1
