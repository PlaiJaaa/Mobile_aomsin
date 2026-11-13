import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'constant/app_constant.dart';
import 'constant/theme_data.dart';
import 'model/user_data.dart';
import 'screens/admin_main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tenant_main_screen.dart';
import 'service/pref_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // โหลดข้อมูลชื่อเดือนภาษาไทยให้ package intl
  await initializeDateFormatting('th');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PrefService prefService = PrefService();

  ThemeMode _themeMode = ThemeMode.light; // ค่าเริ่มต้นเป็น Light Mode
  UserData? _loginUser; // ผู้ใช้ที่ล็อกอินอยู่ (null = ยังไม่ล็อกอิน)

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  // อ่านธีมที่ผู้ใช้เคยเลือกไว้จาก shared_preferences
  void loadTheme() async {
    bool isDark = await prefService.getDarkMode();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // สลับธีมสว่าง/มืด แล้วจำค่าไว้ในเครื่อง
  void toggleTheme() {
    setState(() {
      _themeMode = (_themeMode == ThemeMode.light)
          ? ThemeMode.dark
          : ThemeMode.light;
    });
    prefService.saveDarkMode(_themeMode == ThemeMode.dark);
  }

  // หน้า Splash และหน้า Login เรียกฟังก์ชันนี้เมื่อรู้แล้วว่าใครล็อกอิน
  void setLoginUser(UserData user) {
    setState(() {
      _loginUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode, // set theme เปลี่ยนได้ตรงนี้
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: '/', // เส้นทางเริ่มต้น
      routes: {
        '/': (context) => SplashScreen(onLogin: setLoginUser),
        '/login': (context) => LoginScreen(onLogin: setLoginUser),
        // ส่งข้อมูลผู้ใช้และฟังก์ชันสลับธีมให้หน้าหลักผ่าน constructor
        // ถ้ายังไม่มีผู้ใช้ (เช่น พิมพ์ URL เข้ามาตรง ๆ บนเว็บ) ให้กลับไปหน้า Login
        '/tenant': (context) => _loginUser == null
            ? LoginScreen(onLogin: setLoginUser)
            : TenantMainScreen(user: _loginUser!, switchMode: toggleTheme),
        '/admin': (context) => _loginUser == null
            ? LoginScreen(onLogin: setLoginUser)
            : AdminMainScreen(user: _loginUser!, switchMode: toggleTheme),
      },
      // จำกัดความกว้างสูงสุดของแอป ให้เปิดบนเว็บหรือจอกว้างแล้วยังเป็นสัดส่วนมือถือ
      builder: (context, child) {
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ClipRect(child: child),
            ),
          ),
        );
      },
    );
  }
}
