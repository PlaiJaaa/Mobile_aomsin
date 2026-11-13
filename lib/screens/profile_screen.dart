import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../constant/color.dart';
import '../model/user_data.dart';
import '../service/pref_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/info_row.dart';

// เมนูโปรไฟล์ ใช้ร่วมกันทั้งผู้เช่าและผู้ดูแล: ข้อมูลผู้ใช้ สลับธีม และออกจากระบบ
class ProfileScreen extends StatefulWidget {
  final UserData user;
  final VoidCallback switchMode; // ฟังก์ชันสลับธีมที่ส่งต่อมาจาก main.dart

  const ProfileScreen({
    super.key,
    required this.user,
    required this.switchMode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PrefService prefService = PrefService();

  Future<void> logout() async {
    bool isConfirm = await showConfirmDialog(
      context,
      title: 'ออกจากระบบ',
      message: 'ต้องการออกจากระบบใช่หรือไม่',
      confirmText: 'ออกจากระบบ',
    );
    if (!isConfirm) return;

    // ลบผู้ใช้ที่จำไว้ในเครื่อง แล้วกลับไปหน้าเข้าสู่ระบบ
    await prefService.clearLoginUser();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final UserData user = widget.user;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isAdmin = user.role == roleAdmin;
    // ดูจากธีมที่ใช้อยู่ตอนนี้ว่าเป็นโหมดมืดหรือไม่
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ---------- ส่วนหัว: รูปแทนตัว ชื่อ บทบาท ----------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF14B8A6), primaryDarkColor],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Icon(
                    isAdmin
                        ? Icons.admin_panel_settings_rounded
                        : Icons.person_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isAdmin ? 'ผู้ดูแลหอพัก' : 'ผู้เช่า ห้อง ${user.room}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---------- ข้อมูลบัญชี ----------
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  InfoRow(label: 'ชื่อผู้ใช้', value: user.username),
                  const Divider(height: 1),
                  InfoRow(
                    label: 'บทบาท',
                    value: isAdmin ? 'ผู้ดูแล' : 'ผู้เช่า',
                  ),
                  if (!isAdmin) ...[
                    const Divider(height: 1),
                    InfoRow(label: 'ห้องพัก', value: user.room),
                  ],
                  const Divider(height: 1),
                  InfoRow(label: 'เบอร์โทร', value: user.phone),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ---------- สลับธีม ----------
          Card(
            clipBehavior: Clip.antiAlias,
            child: SwitchListTile(
              title: const Text('โหมดมืด'),
              subtitle: const Text('แอปจะจำค่านี้ไว้ในเครื่อง'),
              secondary: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  key: ValueKey(isDarkMode),
                  color: colorScheme.primary,
                ),
              ),
              value: isDarkMode,
              onChanged: (bool value) {
                widget.switchMode();
              },
            ),
          ),
          const SizedBox(height: 24),

          // ---------- ออกจากระบบ ----------
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: dangerColor,
                side: const BorderSide(color: dangerColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('ออกจากระบบ'),
            ),
          ),
        ],
      ),
    );
  }
}
