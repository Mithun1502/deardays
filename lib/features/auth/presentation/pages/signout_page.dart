import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dear_days/features/auth/bloc/auth_bloc.dart';

class SignOutPage extends StatelessWidget {
  const SignOutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Out')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text("Sign Out"),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            context.read<AuthBloc>().add(SignOutEvent());
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);

            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          },
        ),
      ),
    );
  }
}
