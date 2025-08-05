import 'package:dear_days/features/auth/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:dear_days/features/settings/theme/theme_bloc.dart';
import 'package:dear_days/features/diary/bloc/diary_bloc.dart';
import 'package:dear_days/core/utils/shared_prefs_helper.dart';
import 'package:dear_days/app_theme.dart';
import 'package:dear_days/features/diary/presentation/pages/diary_list_page.dart';
import 'package:dear_days/features/security/security_checker.dart';
import 'package:dear_days/features/auth/data/auth_repository.dart';
import 'package:dear_days/features/auth/bloc/auth_bloc.dart';
import 'package:dear_days/features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await SharedPrefsHelper.init();

  runApp(const DearDaysApp());
}

class DearDaysApp extends StatelessWidget {
  const DearDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return DiaryListPage();
        } else if (state is Unauthenticated) {
          return LoginPage();
        } else if (state is AuthLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return const Scaffold(
            body: Center(child: Text("Checking authentication...")),
          );
        }
      },
    );
  }
}
