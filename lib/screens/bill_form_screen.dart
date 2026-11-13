import 'package:flutter/material.dart';

import '../constant/app_constant.dart';
import '../constant/app_format.dart';
import '../model/bill_data.dart';
import '../service/bill_service.dart';
import '../service/user_service.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/info_row.dart';
import '../widgets/loading_view.dart';
import '../widgets/primary_button.dart';

// ฟอร์มออกบิลของผู้ดูแล: เลือกห้อง รอบบิล แล้วกรอกค่าเช่า ค่าน้ำ ค่าไฟ
class BillFormScreen extends StatefulWidget {
  const BillFormScreen({super.key});

  @override
  State<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends State<BillFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _electricController = TextEditingController();

  final BillService billService = BillService();
  final UserService userService = UserService();

  List<String> _rooms = []; // เลขห้องของผู้เช่าทั้งหมด (ตัวเลือกใน Dropdown)
  bool _isLoadingRooms = true;
  String? _loadErrorMessage; // ข้อความ error ตอนโหลดเลขห้อง (null = ไม่มี)

  String? _selectedRoom;
  int? _selectedMonth = DateTime.now().month;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // ค่าเริ่มต้นของปีเป็น พ.ศ. ปัจจุบัน
    _yearController.text = (DateTime.now().year + 543).toString();
    loadRooms();
  }

  @override
  void dispose() {
    _yearController.dispose();
    _rentController.dispose();
    _waterController.dispose();
    _electricController.dispose();
    super.dispose();
  }

  // โหลดเลขห้องของผู้เช่าจาก server (GET /users?role=tenant)
  Future<void> loadRooms() async {
    setState(() {
      _isLoadingRooms = true;
      _loadErrorMessage = null;
    });

    try {
      List<String> rooms = await userService.getTenantRooms();
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
        _isLoadingRooms = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadErrorMessage = e.toString();
        _isLoadingRooms = false;
      });
    }
  }

  // แปลงข้อความในช่องกรอกเป็นตัวเลข ถ้าแปลงไม่ได้ให้เป็น 0
  double toNumber(String text) {
    return double.tryParse(text.trim()) ?? 0;
  }

  // ยอดรวมจากค่าที่กรอกอยู่ตอนนี้
  double get total {
    return toNumber(_rentController.text) +
        toNumber(_waterController.text) +
        toNumber(_electricController.text);
  }

  // validator ของช่องจำนวนเงิน
  String? validateMoney(String? value, String label, bool mustMoreThanZero) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอก$label';
    }
    double? amount = double.tryParse(value.trim());
    if (amount == null) {
      return '$labelต้องเป็นตัวเลข';
    }
    if (amount < 0) {
      return '$labelต้องไม่ติดลบ';
    }
    if (mustMoreThanZero && amount == 0) {
      return '$labelต้องมากกว่า 0';
    }
    return null;
  }

  Future<void> submitBill() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final int year = int.parse(_yearController.text.trim());

    try {
      // กันออกบิลซ้ำ: ห้องเดียวกัน เดือน/ปีเดียวกัน
      bool isExists = await billService.isBillExists(
        _selectedRoom!,
        _selectedMonth!,
        year,
      );
      if (!mounted) return;

      if (isExists) {
        showErrorSnackBar(
          context,
          'ห้อง $_selectedRoom มีบิลรอบ ${thaiMonths[_selectedMonth! - 1]} $year แล้ว',
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      BillData bill = BillData(
        id: '',
        room: _selectedRoom!,
        month: _selectedMonth!,
        year: year,
        rent: toNumber(_rentController.text),
        water: toNumber(_waterController.text),
        electric: toNumber(_electricController.text),
        status: billUnpaid,
        paymentRef: '',
        createdAt: DateTime.now(),
      );

      await billService.createBill(bill);
      if (!mounted) return;
      showSuccessSnackBar(context, 'ออกบิลห้อง $_selectedRoom เรียบร้อย');
      // กลับไปหน้ารายการบิล พร้อมส่ง true ให้หน้ารายการโหลดใหม่
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.toString());
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ออกบิลใหม่')),
      body: buildBody(),
    );
  }

  // เนื้อหาของหน้า เปลี่ยนตามสถานะการโหลดเลขห้อง
  Widget buildBody() {
    if (_isLoadingRooms) {
      return const LoadingView();
    }
    if (_loadErrorMessage != null) {
      return ErrorView(message: _loadErrorMessage!, onRetry: loadRooms);
    }
    if (_rooms.isEmpty) {
      return const EmptyView(
        icon: Icons.meeting_room_outlined,
        title: 'ยังไม่มีผู้เช่าในระบบ',
        message: 'ต้องมีบัญชีผู้เช่าอย่างน้อย 1 ห้องก่อนจึงจะออกบิลได้',
      );
    }
    return buildForm();
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ---------- ห้อง ----------
          DropdownButtonFormField(
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'ห้องพัก',
              prefixIcon: Icon(Icons.meeting_room_outlined),
            ),
            value: _selectedRoom,
            items: _rooms
                .map(
                  (String item) =>
                      DropdownMenuItem(value: item, child: Text('ห้อง $item')),
                )
                .toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedRoom = value;
              });
            },
            validator: (String? value) {
              if (value == null) {
                return 'กรุณาเลือกห้องพัก';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ---------- รอบบิล: เดือน + ปี ----------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField(
                  isExpanded: true, // ให้ชื่อเดือนยาว ๆ ไม่ล้นช่อง
                  decoration: const InputDecoration(labelText: 'เดือน'),
                  value: _selectedMonth,
                  // สร้างตัวเลือกเดือน 1-12 จากรายชื่อเดือนภาษาไทย
                  items: List.generate(thaiMonths.length, (int index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(thaiMonths[index]),
                    );
                  }),
                  onChanged: (int? value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                  validator: (int? value) {
                    if (value == null) {
                      return 'กรุณาเลือกเดือน';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ปี พ.ศ.'),
                  validator: (String? value) {
                    int? year = int.tryParse(value?.trim() ?? '');
                    if (year == null) {
                      return 'กรอกปี พ.ศ.';
                    }
                    if (year < 2500 || year > 2700) {
                      return 'ปีไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ---------- จำนวนเงิน ----------
          TextFormField(
            controller: _rentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'ค่าเช่าห้อง (บาท)',
              prefixIcon: Icon(Icons.home_work_outlined),
            ),
            // พิมพ์แล้ว setState เพื่อให้ยอดรวมด้านล่างอัปเดตทันที
            onChanged: (String value) => setState(() {}),
            validator: (String? value) =>
                validateMoney(value, 'ค่าเช่าห้อง', true),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _waterController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'ค่าน้ำ (บาท)',
              prefixIcon: Icon(Icons.water_drop_outlined),
            ),
            onChanged: (String value) => setState(() {}),
            validator: (String? value) => validateMoney(value, 'ค่าน้ำ', false),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _electricController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'ค่าไฟ (บาท)',
              prefixIcon: Icon(Icons.bolt_outlined),
            ),
            onChanged: (String value) => setState(() {}),
            validator: (String? value) => validateMoney(value, 'ค่าไฟ', false),
          ),
          const SizedBox(height: 16),

          // ---------- ยอดรวม ----------
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: InfoRow(
                label: 'ยอดรวม',
                value: formatMoney(total),
                isBold: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'ออกบิล',
            icon: Icons.receipt_long_rounded,
            isLoading: _isSaving,
            onPressed: submitBill,
          ),
        ],
      ),
    );
  }
}
