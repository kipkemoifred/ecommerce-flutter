import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';
import '../customer/customer_main_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'sarh@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  String _selectedRole = AppConstants.roleCustomer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillPreset(String role) {
    setState(() {
      _selectedRole = role;
      if (role == AppConstants.roleCustomer) {
        _emailController.text = 'sarh@example.com';
        _passwordController.text = 'customer123';
      } else if (role == AppConstants.roleSeller) {
        _emailController.text = 'seller@technest.com';
        _passwordController.text = 'seller123';
      } else if (role == AppConstants.roleAdmin) {
        _emailController.text = 'admin@shopnest.com';
        _passwordController.text = 'admin123';
      }
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final auth = Get.find<AuthController>();
      final success = await auth.login(
        _emailController.text,
        _passwordController.text,
        targetRole: _selectedRole,
      );

      if (success) {
        if (auth.isAdmin) {
          Get.offAll(() => const AdminDashboardScreen());
        } else if (auth.isSeller) {
          Get.offAll(() => const SellerDashboardScreen());
        } else {
          Get.offAll(() => const CustomerMainScreen());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: [
          TextButton(
            onPressed: () => Get.offAll(() => const CustomerMainScreen()),
            child: const Text('Browse as Guest'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Welcome to ShopNest',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Multi-vendor e-commerce marketplace',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Quick Demo Role selector chips
                const Text(
                  'Quick Role Selection (Demo):',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRoleChip(AppConstants.roleCustomer, 'Customer', AppColors.customerBadge),
                    const SizedBox(width: 8),
                    _buildRoleChip(AppConstants.roleSeller, 'Seller', AppColors.sellerBadge),
                    const SizedBox(width: 8),
                    _buildRoleChip(AppConstants.roleAdmin, 'Admin', AppColors.adminBadge),
                  ],
                ),
                const SizedBox(height: 24),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Get.snackbar(
                        'Password Reset',
                        'Password reset instructions sent to ${_emailController.text}',
                      );
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                Obx(() => CustomButton(
                      text: 'Sign In',
                      isLoading: auth.isLoading.value,
                      onPressed: _handleLogin,
                    )),
                const SizedBox(height: 24),

                // Don't have an account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const RegisterScreen()),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, String label, Color color) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => _fillPreset(role),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}
