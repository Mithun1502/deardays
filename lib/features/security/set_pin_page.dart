import 'package:flutter/material.dart';
import 'package:dear_days/features/security/pin_helper.dart';

class SetPinPage extends StatefulWidget {
  const SetPinPage({super.key});

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final TextEditingController _pinController = TextEditingController();

  void _savePin() async {
    final pin = _pinController.text.trim();

    if (pin.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PIN must be 4 digits")));
      return;
    }

    await PinHelper.savePin(pin);
    Navigator.pop(context, true); // Go back after setting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Enter a 4-digit PIN to secure your diary."),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "New PIN",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _savePin, child: const Text("Set PIN")),
          ],
        ),
      ),
    );
  }
}
