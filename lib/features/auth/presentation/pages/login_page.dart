import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dear_days/features/auth/bloc/auth_bloc.dart';
import 'package:dear_days/features/settings/theme/theme_bloc.dart';
import 'package:dear_days/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthBloc>().add(
            LoginWithEmailEvent(email, password),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDarkMode;
    final gradient = isDark ? darkGradient : lightGradient;
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      isDark ? Icons.wb_sunny : Icons.nightlight_round,
                      color: isDark ? Colors.white : Colors.blueGrey.shade800,
                    ),
                    onPressed: () {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    },
                    tooltip: 'Toggle Dark Mode',
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : const Color.fromARGB(255, 1, 14, 24)),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        color: isDark
                            ? Colors.white
                            : const Color.fromARGB(255, 1, 14, 24)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        color: isDark
                            ? Colors.white
                            : const Color.fromARGB(255, 1, 14, 24)),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _login(context),
                    child: Text(
                      'Login',
                      style: TextStyle(
                          fontSize: 18,
                          color: isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 1, 14, 24),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                        fontSize: 18,
                        color: isDark
                            ? Colors.white
                            : const Color.fromARGB(255, 1, 14, 24),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/phone-login');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone,
                        color: isDark
                            ? Colors.white
                            : const Color.fromARGB(255, 1, 14, 24),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Login with Phone Number",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 1, 14, 24),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
