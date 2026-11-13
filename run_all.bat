@echo off
chcp 65001 >nul
title dorm_app - run all
rem ===== ดับเบิลคลิกครั้งเดียว: เปิด server + เปิด Android Emulator + รันแอป =====
rem 1) เปิด server ในหน้าต่างแยก (ถ้ายังไม่ได้เปิด)
rem 2) เปิด emulator ตัวแรกที่มีในเครื่อง (ถ้ายังไม่ได้เปิด) แล้วรอจน boot เสร็จ
rem 3) flutter run -d emulator

cd /d "%~dp0"

rem ---------- ตรวจโปรแกรมที่ต้องใช้ ----------
where flutter >nul 2>nul
if errorlevel 1 goto no_flutter
where node >nul 2>nul
if errorlevel 1 goto no_node

rem ---------- หาที่อยู่ Android SDK ----------
set "SDK=%LOCALAPPDATA%\Android\Sdk"
if defined ANDROID_SDK_ROOT set "SDK=%ANDROID_SDK_ROOT%"
if defined ANDROID_HOME set "SDK=%ANDROID_HOME%"
set "ADB=%SDK%\platform-tools\adb.exe"
set "EMU=%SDK%\emulator\emulator.exe"
if not exist "%ADB%" goto no_sdk
if not exist "%EMU%" goto no_sdk

rem ---------- 1) server ----------
echo [1/3] ตรวจ server ...
curl.exe -s -o nul http://127.0.0.1:3000/users
if not errorlevel 1 goto server_ok
echo       ยังไม่ได้เปิด กำลังเปิด server ในหน้าต่างใหม่ [ห้ามปิดหน้าต่างนั้น]
start "dorm_app server" cmd /c call "%~dp0start_server.bat"
set /a TRIES=0
:wait_server
curl.exe -s -o nul http://127.0.0.1:3000/users
if not errorlevel 1 goto server_ok
set /a TRIES+=1
if %TRIES% geq 120 goto server_fail
ping -n 2 127.0.0.1 >nul
goto wait_server
:server_ok
echo       server พร้อมที่ http://localhost:3000

rem ---------- 2) emulator ----------
echo [2/3] ตรวจ Android Emulator ...
"%ADB%" start-server >nul 2>nul
"%ADB%" devices | findstr /b "emulator-" >nul
if not errorlevel 1 goto wait_boot
set "AVD="
for /f "delims=" %%a in ('call "%EMU%" -list-avds 2^>nul') do if not defined AVD set "AVD=%%a"
if not defined AVD goto no_avd
echo       กำลังเปิด emulator %AVD% ...
start "" "%EMU%" -avd %AVD%
:wait_boot
echo       รอ emulator boot ให้เสร็จ [ครั้งแรกอาจใช้ 1-3 นาที] ...
"%ADB%" wait-for-device
set /a TRIES=0
:wait_boot_loop
"%ADB%" shell getprop sys.boot_completed 2>nul | findstr "1" >nul
if not errorlevel 1 goto boot_ok
set /a TRIES+=1
if %TRIES% geq 180 goto boot_fail
ping -n 2 127.0.0.1 >nul
goto wait_boot_loop
:boot_ok
echo       emulator พร้อมแล้ว

rem ---------- 3) รันแอป ----------
echo [3/3] รันแอปบน emulator [ครั้งแรก build 2-5 นาที]
echo       ระหว่างรัน: กด r = hot reload, R = hot restart, q = ปิดแอป
call flutter pub get
call flutter run -d emulator
echo.
echo แอปหยุดทำงานแล้ว (server ยังเปิดอยู่ในอีกหน้าต่าง ปิดหน้าต่างนั้นเพื่อปิด server)
pause
exit /b 0

rem ---------- ข้อความผิดพลาด ----------
:no_flutter
echo [ผิดพลาด] ไม่พบคำสั่ง flutter กรุณาติดตั้ง Flutter และเพิ่มลง PATH ดู HOW_TO_RUN.md ขั้นที่ 1
pause
exit /b 1
:no_node
echo [ผิดพลาด] ไม่พบ Node.js กรุณาติดตั้งจาก https://nodejs.org
pause
exit /b 1
:no_sdk
echo [ผิดพลาด] ไม่พบ Android SDK ที่ %SDK%
echo กรุณาติดตั้ง Android Studio หรือตั้งค่า ANDROID_HOME ให้ชี้ไปที่ Android SDK
pause
exit /b 1
:no_avd
echo [ผิดพลาด] ยังไม่มี emulator ในเครื่อง สร้างได้ที่ Android Studio ^> Device Manager ^> Create Virtual Device
pause
exit /b 1
:server_fail
echo [ผิดพลาด] เปิด server ไม่สำเร็จภายใน 2 นาที ดูข้อความในหน้าต่าง "dorm_app server"
pause
exit /b 1
:boot_fail
echo [ผิดพลาด] emulator boot ไม่เสร็จภายใน 3 นาที ลองเปิดจาก Android Studio ^> Device Manager แล้วรันไฟล์นี้ใหม่
pause
exit /b 1
