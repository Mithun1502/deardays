import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dear_days/features/auth/bloc/auth_bloc.dart';
//import 'package:dear_days/app_theme.dart';

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid phone number")),
      );
    }
  }

  void _verifyOtp(BuildContext context) {
    final otp = _otpController.text.trim();
    if (otp.isNotEmpty && (_verificationId?.isNotEmpty ?? false)) {
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Phone Login",
          style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        centerTitle: true,
        toolbarHeight: 96,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 3, 60, 86), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpSent) {
              setState(() {
                _verificationId = state.verificationId;
                otpSent = true;
              });
            } else if (state is AuthSuccess) {
              _phoneController.clear();
              _otpController.clear();
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 64),
                    if (!otpSent)
                      TextField(
                        style: const TextStyle(
                          color: Color.fromARGB(255, 7, 13, 88),
                          fontWeight: FontWeight.w700,
                        ),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (e.g. +919876543210)',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(255, 5, 68, 124),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.transparent,
                          focusColor: Colors.amber,
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
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 1, 11, 20),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color.fromARGB(255, 255, 255, 255),
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
                        child: const Text(
                          'Send OTP',
                          style: TextStyle(
                              color: Color.fromARGB(255, 103, 158, 203),
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
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
      ),
    );
  }
}
