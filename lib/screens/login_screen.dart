import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/gradient_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/encryption_footer.dart';
import '../viewmodels/login_view_model.dart';
import 'scheme_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _submitted = false;

  void _handleSignIn(BuildContext context) async {
    setState(() {
      _submitted = true;
    });

    if (_formKey.currentState!.validate()) {
      final loginViewModel = context.read<LoginViewModel>();
      // Capture context-dependent objects before async gap
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      final success = await loginViewModel.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to Screen 2 (Scheme List)
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const SchemeListScreen()),
        );
      } else if (mounted && loginViewModel.errorMessage != null) {
        // Show validation/login error message
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(loginViewModel.errorMessage!)),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        top: false, // Let gradient header draw behind status bar
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // Header Widget
              const GradientHeader(
                title: 'FundBrowser',
                subtitle: 'Your mutual fund companion',
                icon: Icons.trending_up_rounded,
              ),
              
              // Form Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Address Input
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email address',
                        hintText: 'you@example.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Password Input
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Sign In Button
                      PrimaryButton(
                        text: 'Sign in',
                        isLoading: loginViewModel.isLoading,
                        onPressed: () => _handleSignIn(context),
                      ),
                      const SizedBox(height: 48),
                      
                      // Encryption Footer
                      const EncryptionFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
