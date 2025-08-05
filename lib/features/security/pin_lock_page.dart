import 'package:flutter/material.dart';
import 'package:dear_days/features/security/pin_helper.dart';

class PinLockPage extends StatefulWidget {
  const PinLockPage({super.key});

  @override
  State<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends State<PinLockPage> {
  final TextEditingController _pinController = TextEditingController();

  void _validatePin() {
    final inputPin = _pinController.text.trim();

    if (PinHelper.isPinCorrect(inputPin)) {
      Navigator.pop(context, true); // Unlock success
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Incorrect PIN")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Enter your 4-digit PIN to unlock."),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "PIN",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validatePin,
              child: const Text("Unlock"),
            ),
          ],
        ),
      ),
    );
  }
}
