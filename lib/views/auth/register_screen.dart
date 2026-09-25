import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';
import '../customer/customer_main_screen.dart';
import '../seller/seller_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storeDescController = TextEditingController();

  String _selectedRole = AppConstants.roleCustomer;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _storeNameController.dispose();
    _storeDescController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final auth = Get.find<AuthController>();
      final success = await auth.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
        storeName: _storeNameController.text,
        storeDescription: _storeDescController.text,
      );

      if (success) {
        if (_selectedRole == AppConstants.roleSeller) {
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
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join ShopNest Marketplace',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose whether you are shopping or selling today',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // Role Selector Tabs (Customer vs Seller)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedRole = AppConstants.roleCustomer),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedRole == AppConstants.roleCustomer
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedRole == AppConstants.roleCustomer
                                  ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18,
                                  color: _selectedRole == AppConstants.roleCustomer
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Customer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedRole == AppConstants.roleCustomer
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedRole = AppConstants.roleSeller),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedRole == AppConstants.roleSeller
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedRole == AppConstants.roleSeller
                                  ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 18,
                                  color: _selectedRole == AppConstants.roleSeller
                                      ? AppColors.sellerBadge
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Seller / Merchant',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedRole == AppConstants.roleSeller
                                        ? AppColors.sellerBadge
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'John Doe',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'john@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
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
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                // Additional Seller Fields
                if (_selectedRole == AppConstants.roleSeller) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.sellerBadge.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.sellerBadge.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Store Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.sellerBadge,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _storeNameController,
                          label: 'Store / Brand Name',
                          hintText: 'Apex Gadgets',
                          prefixIcon: Icons.business_outlined,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Please provide your store name' : null,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _storeDescController,
                          label: 'Store Tagline / Description',
                          hintText: 'Curated tech and accessories',
                          prefixIcon: Icons.description_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Submit
                Obx(() => CustomButton(
                      text: _selectedRole == AppConstants.roleSeller
                          ? 'Open Seller Store'
                          : 'Create Customer Account',
                      backgroundColor: _selectedRole == AppConstants.roleSeller
                          ? AppColors.sellerBadge
                          : AppColors.primary,
                      isLoading: auth.isLoading.value,
                      onPressed: _handleRegister,
                    )),
                const SizedBox(height: 20),

                // Back to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?', style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
