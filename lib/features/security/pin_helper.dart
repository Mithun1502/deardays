import 'package:dear_days/core/utils/shared_prefs_helper.dart';

class PinHelper {
  static Future<void> savePin(String pin) async {
    await SharedPrefsHelper.savePin(pin);
  }

  static String? getSavedPin() {
    return SharedPrefsHelper.getPin();
  }

  static Future<void> removePin() async {
    await SharedPrefsHelper.removePin();
  }

  static bool hasPin() {
    final pin = getSavedPin();
    return pin != null && pin.isNotEmpty;
  }

  static bool isPinCorrect(String inputPin) {
    final savedPin = getSavedPin();
    return savedPin == inputPin;
  }
}
