import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:dear_days/app_theme.dart';
import 'package:dear_days/features/auth/bloc/auth_bloc.dart';
import 'package:dear_days/features/auth/data/auth_repository.dart';
import 'package:dear_days/features/auth/presentation/pages/login_page.dart';
import 'package:dear_days/features/auth/presentation/pages/signup_page.dart';
import 'package:dear_days/features/auth/presentation/pages/phone_login_page.dart';
import 'package:dear_days/features/auth/presentation/pages/signout_page.dart';
import 'package:dear_days/features/diary/bloc/diary_bloc.dart';
import 'package:dear_days/features/diary/presentation/pages/diary_list_page.dart';
import 'package:dear_days/features/settings/theme/theme_bloc.dart';
import 'package:dear_days/core/utils/shared_prefs_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await SharedPrefsHelper.init();
  } catch (e, st) {
    print("Initialization error: $e");
    print("Stack trace:\n$st");
  }

  runApp(const DearDaysApp());
}

class DearDaysApp extends StatelessWidget {
  const DearDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthBloc(authRepository: authRepository)..add(AppStarted()),
        ),
        BlocProvider(create: (_) => ThemeBloc()..add(LoadThemeEvent())),
        BlocProvider(create: (_) => DiaryBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Dear Days',
            theme: themeState.isDarkMode ? darkTheme : lightTheme,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/root': (context) => const RootPage(),
              '/login': (context) => const LoginPage(),
              '/home': (context) => const DiaryListPage(),
              '/phone-login': (context) => const PhoneLoginPage(),
              '/signout': (context) => const SignOutPage(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/root');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 120, height: 120),
            const SizedBox(height: 20),
            const Text(
              'Dear Days',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const DiaryListPage();
        } else if (state is AuthFailure) {
          if (state.error == "Logged out") {
            return const SignOutPage();
          }
          return const LoginPage();
        } else if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text("Checking authentication...")),
          );
        }
      },
    );
  }
}
