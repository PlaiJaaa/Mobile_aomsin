import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../model/user_data.dart';
import '../service/pref_service.dart';
import '../widgets/app_logo.dart';

// หน้าแรกตอนเปิดแอป: แสดงโลโก้ แล้วตรวจว่าเคยล็อกอินค้างไว้หรือไม่
// - เคยล็อกอิน -> ไปหน้าหลักตามบทบาท
// - ไม่เคย     -> ไปหน้าเข้าสู่ระบบ
class SplashScreen extends StatefulWidget {
  final void Function(UserData user) onLogin;

  const SplashScreen({super.key, required this.onLogin});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PrefService prefService = PrefService();
  double _opacity = 0; // เริ่มจากโปร่งใส แล้วค่อย ๆ ชัดขึ้น

  @override
  void initState() {
    super.initState();
    showLogo();
    checkLogin();
  }

  // รอให้หน้าจอวาดเสร็จก่อนเล็กน้อย แล้วเปลี่ยน opacity เพื่อให้ AnimatedOpacity ทำงาน
  void showLogo() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() {
      _opacity = 1;
    });
  }

  void checkLogin() async {
    // อ่านผู้ใช้ที่จำไว้ใน shared_preferences
    UserData? user = await prefService.getLoginUser();
    // หน่วงเวลาให้เห็นโลโก้
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    if (user == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      widget.onLogin(user);
      Navigator.pushNamedAndRemoveUntil(
        context,
        user.role == roleAdmin ? '/admin' : '/tenant',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 800),
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(size: 96),
              const SizedBox(height: 20),
              const Text(
                appName,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'จ่ายบิล แจ้งซ่อม ติดตามประกาศ ในแอปเดียว',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
