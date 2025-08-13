import 'dart:async';
import 'package:dear_days/features/auth/presentation/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:dear_days/app_theme.dart';
import 'package:dear_days/features/auth/bloc/auth_bloc.dart';
import 'package:dear_days/features/auth/data/auth_repository.dart';
import 'package:dear_days/features/auth/presentation/pages/phone_login_page.dart';
import 'package:dear_days/features/auth/presentation/pages/signout_page.dart';
import 'package:dear_days/features/diary/bloc/diary_bloc.dart';
import 'package:dear_days/features/diary/presentation/pages/diary_list_page.dart';
import 'package:dear_days/features/settings/theme/theme_bloc.dart';
import 'package:dear_days/core/utils/shared_prefs_helper.dart';
import 'package:dear_days/features/diary/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await SharedPrefsHelper.init();
  } catch (e, st) {
    debugPrint("Initialization error: $e");
    debugPrint("Stack trace:\n$st");
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

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          // Rebuild the UI with a new DiaryBloc for the logged-in user
          return BlocProvider(
            create: (_) => DiaryBloc(userId: state.user.uid),
            child: const DiaryListPage(),
          );
        } else if (state is AuthFailure) {
          if (state.error == "Logged out") {
            return const SignOutPage();
          }
          return const LoginPage();
        } else if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthUnauthenticated) {
          return const LoginPage();
        } else {
          return const Scaffold(
            body: Center(child: Text("Checking authentication...")),
          );
        }
      },
    );
  }
}
