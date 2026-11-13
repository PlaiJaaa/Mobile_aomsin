import 'package:flutter/material.dart';

import '../model/user_data.dart';
import 'admin_bill_screen.dart';
import 'admin_repair_screen.dart';
import 'announcement_screen.dart';
import 'profile_screen.dart';

// หน้าหลักของผู้ดูแล มี BottomNavigationBar 4 เมนู
class AdminMainScreen extends StatefulWidget {
  final UserData user; // ผู้ดูแลที่ล็อกอินอยู่ (รับมาจาก main.dart)
  final VoidCallback switchMode; // ฟังก์ชันสลับธีมจาก main.dart

  const AdminMainScreen({
    super.key,
    required this.user,
    required this.switchMode,
  });

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const AdminBillScreen(key: ValueKey(0)),
      const AdminRepairScreen(key: ValueKey(1)),
      const AnnouncementScreen(key: ValueKey(2), isAdmin: true),
      ProfileScreen(
        key: const ValueKey(3),
        user: widget.user,
        switchMode: widget.switchMode,
      ),
    ];

    return Scaffold(
      // AnimatedSwitcher: จางสลับหน้าเมื่อเปลี่ยนเมนู
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'บิล',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build_rounded),
            label: 'งานซ่อม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign_rounded),
            label: 'ประกาศ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'โปรไฟล์',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
