import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dear_days/features/settings/theme/theme_bloc.dart';
import 'package:dear_days/features/settings/theme/theme_switch.dart';
import 'package:dear_days/core/utils/shared_prefs_helper.dart';
import 'package:dear_days/app_theme.dart';
import 'package:dear_days/features/diary/presentation/pages/diary_list_page.dart';
import 'package:dear_days/features/security/pin_lock_page.dart';
import 'package:dear_days/features/security/security_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsHelper.init(); // Initialize SharedPreferences
  runApp(const DearDaysApp());
}

class DearDaysApp extends StatelessWidget {
  const DearDaysApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc()..add(LoadThemeEvent()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Dear Days',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const SecurityChecker(),
          );
        },
      ),
    );
  }
}
