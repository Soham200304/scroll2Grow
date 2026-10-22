import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:scrool2grow/app/core/widgets/app_button.dart';
import 'package:scrool2grow/app/routes/AppRoutes.dart';
import 'package:scrool2grow/app/themes/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrool2grow/features/auth/viewmodels/SignUpViewModel.dart';
import 'package:scrool2grow/features/home/views/HomePageView.dart';


class SignUpView extends ConsumerStatefulWidget  {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.textSecondary,
      ),
      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(authViewModelProvider).isLoading;
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 60),

              // Logo
              Center(
                child: SizedBox(
                  height: 130,
                  width: 130,
                  child: Lottie.asset(
                    'assets/animations/plant.json',
                    repeat: false,
                    animate: true,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Center(
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Center(
                child: const Text(
                  'Start growing instead of scrolling.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ---------------- NAME ----------------

              const Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: inputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- EMAIL ----------------

              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: inputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- PASSWORD ----------------

              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: inputDecoration(
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- CONFIRM PASSWORD ----------------

              const Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: inputDecoration(
                  hintText: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword =
                        !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- SIGN UP BUTTON ----------------

              AppButton(
                text: 'Create Account',
                isLoading: isLoading,
                onPressed: () async {
                  // Validate fields
                  if (nameController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please fill in all fields.',
                        ),
                      ),
                    );

                    return;
                  }

                  // Check password match
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Passwords do not match.',
                        ),
                      ),
                    );

                    return;
                  }

                  // Call ViewModel
                  final success = await ref
                      .read(authViewModelProvider.notifier)
                      .signup(
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  if (!mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Account created successfully!',
                        ),
                      ),
                    );

                    // Navigate after successful signup
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.home,
                    );

                  } else {
                    final errorMessage =
                        ref.read(authViewModelProvider).errorMessage;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errorMessage ?? 'Signup failed.',
                        ),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // ---------------- OR ----------------

              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      color: AppColors.border,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Divider(
                      color: AppColors.border,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------- GOOGLE ----------------

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    debugPrint('Google Sign Up pressed');
                  },

                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 28,
                    color: Colors.black,
                  ),

                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ---------------- LOGIN ----------------

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}