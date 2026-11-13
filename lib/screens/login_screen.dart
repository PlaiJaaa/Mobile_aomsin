import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../model/user_data.dart';
import '../service/pref_service.dart';
import '../service/user_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/primary_button.dart';

// หน้าเข้าสู่ระบบ ใช้ร่วมกันทั้งผู้เช่าและผู้ดูแล
// ตรวจชื่อผู้ใช้/รหัสผ่านกับข้อมูล users จาก server (GET /users?username=...)
// การเก็บรหัสผ่านแบบนี้เหมาะกับงานสาธิตในรายวิชาเท่านั้น
class LoginScreen extends StatefulWidget {
  final void Function(UserData user) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //TextEditing Controller
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserService userService = UserService();
  final PrefService prefService = PrefService();

  bool _isRemember = true; // จดจำการเข้าสู่ระบบ
  bool _isHidePassword = true; // ซ่อนรหัสผ่าน
  bool _isLoading = false; // กำลังตรวจสอบการเข้าสู่ระบบ

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    // validate ไม่ผ่าน ไม่ต้องทำต่อ
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserData? user = await userService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;

      if (user == null) {
        showErrorSnackBar(context, 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      } else {
        // ติ๊กจดจำไว้ -> บันทึกลงเครื่อง, ไม่ติ๊ก -> ลบของเดิมทิ้ง
        if (_isRemember) {
          await prefService.saveLoginUser(user);
        } else {
          await prefService.clearLoginUser();
        }
        if (!mounted) return;

        widget.onLogin(user);
        // ไปหน้าหลักตามบทบาท และล้างหน้าก่อนหน้าออกจาก Stack ทั้งหมด
        Navigator.pushNamedAndRemoveUntil(
          context,
          user.role == roleAdmin ? '/admin' : '/tenant',
          (route) => false,
        );
        return;
      }
    } catch (e) {
      if (mounted) {
        // เช่น ยังไม่ได้เปิด server จะแสดงข้อความให้เปิด server ก่อน
        showErrorSnackBar(context, e.toString());
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const AppLogo(size: 84),
                  const SizedBox(height: 20),
                  const Text(
                    appName,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'เข้าสู่ระบบเพื่อจัดการบิล แจ้งซ่อม และดูประกาศ',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อผู้ใช้',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกชื่อผู้ใช้';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isHidePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (String value) => login(),
                    decoration: InputDecoration(
                      labelText: 'รหัสผ่าน',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      // ปุ่มแสดง/ซ่อนรหัสผ่าน
                      suffixIcon: IconButton(
                        tooltip: _isHidePassword
                            ? 'แสดงรหัสผ่าน'
                            : 'ซ่อนรหัสผ่าน',
                        onPressed: () {
                          setState(() {
                            _isHidePassword = !_isHidePassword;
                          });
                        },
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isHidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            key: ValueKey(_isHidePassword),
                          ),
                        ),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรหัสผ่าน';
                      }
                      if (value.length < 4) {
                        return 'รหัสผ่านต้องมีอย่างน้อย 4 ตัวอักษร';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),
                  CheckboxListTile(
                    title: const Text('จดจำการเข้าสู่ระบบ'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _isRemember,
                    onChanged: (bool? value) {
                      setState(() {
                        _isRemember = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    text: 'เข้าสู่ระบบ',
                    icon: Icons.login_rounded,
                    isLoading: _isLoading,
                    onPressed: login,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
