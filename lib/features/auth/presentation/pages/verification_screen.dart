import 'package:flutter/material.dart';
import 'dart:async';
import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:azt/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isResending = false;
  
  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      BlocProvider.of<AuthCubit>(context).checkEmailVerification();
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    await BlocProvider.of<AuthCubit>(context).resendVerificationEmail();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent!')),
      );
      setState(() => _isResending = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = BlocProvider.of<AuthCubit>(context).state;
    final userEmail = authState is EmailNotVerified ? authState.user.email : 'your email';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => BlocProvider.of<AuthCubit>(context).logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification email to\n$userEmail',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your inbox and click the verification link.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => BlocProvider.of<AuthCubit>(context).checkEmailVerification(),
                icon: const Icon(Icons.refresh),
                label: const Text('I\'ve verified my email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isResending ? null : _resendEmail,
                child: Text(
                  _isResending ? 'Sending...' : 'Resend verification email',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}