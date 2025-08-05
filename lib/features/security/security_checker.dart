import 'package:flutter/material.dart';
import 'package:dear_days/features/security/pin_helper.dart';
import 'package:dear_days/features/security/pin_lock_page.dart';
import 'package:dear_days/features/diary/presentation/pages/diary_list_page.dart';

class SecurityChecker extends StatefulWidget {
  const SecurityChecker({super.key});

  @override
  State<SecurityChecker> createState() => _SecurityCheckerState();
}

class _SecurityCheckerState extends State<SecurityChecker> {
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    if (PinHelper.hasPin()) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PinLockPage()),
      );

      if (result == true) {
        setState(() => _isUnlocked = true);
      }
    } else {
      setState(() => _isUnlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isUnlocked
        ? const DiaryListPage()
        : const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
