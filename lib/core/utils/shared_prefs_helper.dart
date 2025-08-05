import 'package:shared_preferences/shared_preferences.dart';
import 'package:dear_days/config/constants.dart';

class SharedPrefsHelper {
  static late SharedPreferences _prefs;

  // Call this once in main()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Dark Mode
  static Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(AppConstants.keyIsDarkMode, isDark);
  }

  static bool get isDarkMode =>
      _prefs.getBool(AppConstants.keyIsDarkMode) ?? false;

  // PIN Code
  static Future<void> savePin(String pin) async {
    await _prefs.setString(AppConstants.keyPinCode, pin);
  }

  static String? getPin() {
    return _prefs.getString(AppConstants.keyPinCode);
  }

  static Future<void> removePin() async {
    await _prefs.remove(AppConstants.keyPinCode);
  }
}
