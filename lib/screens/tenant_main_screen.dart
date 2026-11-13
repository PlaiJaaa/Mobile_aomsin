import 'package:flutter/material.dart';

import '../model/user_data.dart';
import 'announcement_screen.dart';
import 'profile_screen.dart';
import 'tenant_bill_screen.dart';
import 'tenant_home_screen.dart';
import 'tenant_repair_screen.dart';

// หน้าหลักของผู้เช่า มี BottomNavigationBar 5 เมนู
class TenantMainScreen extends StatefulWidget {
  final UserData user; // ผู้เช่าที่ล็อกอินอยู่ (รับมาจาก main.dart)
  final VoidCallback switchMode; // ฟังก์ชันสลับธีมจาก main.dart

  const TenantMainScreen({
    super.key,
    required this.user,
    required this.switchMode,
  });

  @override
  State<TenantMainScreen> createState() => _TenantMainScreenState();
}

class _TenantMainScreenState extends State<TenantMainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // หน้าของแต่ละเมนู ส่งข้อมูลผู้ใช้ต่อให้ผ่าน constructor
    // key ใช้บอก AnimatedSwitcher ว่าเป็นคนละหน้ากัน
    final List<Widget> widgetOptions = <Widget>[
      TenantHomeScreen(
        key: const ValueKey(0),
        user: widget.user,
        onChangeTab: _onItemTapped,
      ),
      TenantBillScreen(key: const ValueKey(1), user: widget.user),
      TenantRepairScreen(key: const ValueKey(2), user: widget.user),
      const AnnouncementScreen(key: ValueKey(3), isAdmin: false),
      ProfileScreen(
        key: const ValueKey(4),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'บิล',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build_rounded),
            label: 'แจ้งซ่อม',
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
