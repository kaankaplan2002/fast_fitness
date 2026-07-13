import 'package:fast_fitness/app/theme.dart';
import 'package:fast_fitness/features/auth/presentation/providers/auth_provider.dart';
import 'package:fast_fitness/features/auth/presentation/widgets/auth_button.dart';
import 'package:fast_fitness/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email address.', isError: true);
      return;
    }

    try {
      ref.read(authLoadingProvider.notifier).setLoading(true);

      await ref.read(authRemoteDatasourceProvider).sendPasswordResetEmail(
            email: email,
          );

      _showMessage(
        'Password reset link sent. Please check your email.',
        isError: false,
      );

      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Password reset failed.', isError: true);
    } catch (_) {
      _showMessage('Something went wrong.', isError: true);
    } finally {
      ref.read(authLoadingProvider.notifier).setLoading(false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 26),
              IconButton(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(height: 34),
              const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter your email address and we will send you a password reset link.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              AuthTextField(
                controller: emailController,
                hintText: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 28),
              AuthButton(
                text: 'Send Reset Link',
                isLoading: isLoading,
                onPressed: _sendResetLink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}