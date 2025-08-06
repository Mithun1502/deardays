import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dear_days/features/auth/bloc/auth_bloc.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool otpSent = false;
  String? _verificationId;

  void _sendOtp(BuildContext context) {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isNotEmpty) {
      context.read<AuthBloc>().add(SendOtpEvent(phoneNumber));
      setState(() {
        otpSent = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid phone number")),
      );
    }
  }

  void _verifyOtp(BuildContext context) {
    final otp = _otpController.text.trim();
    if (otp.isNotEmpty && _verificationId != null) {
      context.read<AuthBloc>().add(VerifyOtpEvent(otp, _verificationId!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter OTP")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Login")),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSent) {
            setState(() {
              _verificationId = state.verificationId;
              otpSent = true;
            });
          } else if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Phone Login',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  if (!otpSent)
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (e.g. +919876543210)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  if (otpSent)
                    Column(
                      children: [
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Enter OTP',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _verifyOtp(context),
                          child: const Text('Verify OTP'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  if (!otpSent)
                    ElevatedButton(
                      onPressed: () => _sendOtp(context),
                      child: const Text('Send OTP'),
                    ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const CircularProgressIndicator();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
