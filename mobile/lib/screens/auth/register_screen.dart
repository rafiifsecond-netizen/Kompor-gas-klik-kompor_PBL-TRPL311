import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'customer';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      address: _addressController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted || !ok) return;

    final route = auth.isTechnician
        ? AppRoutes.technicianDashboard
        : AppRoutes.customerHome;
    Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Buat Akun Baru')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(key: _formKey, child: _buildFormContent()),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    final auth = context.watch<AuthProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoleSelector(),
        const SizedBox(height: 12),
        if (auth.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              auth.errorMessage!,
              style: const TextStyle(fontSize: 12, color: AppColors.danger),
            ),
          ),
        CustomTextField(
          label: 'Nama Lengkap',
          hint: 'contoh: Budi Santoso',
          controller: _nameController,
          prefixIcon: Icons.person_outline_rounded,
          errorText: auth.getFieldError('name'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Nomor WhatsApp / HP',
          hint: 'contoh: 081234567890',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_android_rounded,
          errorText: auth.getFieldError('phone'),
          validator: (v) => (v == null || v.trim().length < 9) ? 'Nomor HP tidak valid' : null,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Alamat Email',
          hint: 'contoh: budi@gmail.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          errorText: auth.getFieldError('email'),
          validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Alamat Tempat Tinggal',
          hint: 'Alamat lengkap tempat tinggal',
          controller: _addressController,
          prefixIcon: Icons.location_on_outlined,
          errorText: auth.getFieldError('address'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Kata Sandi',
          hint: 'Minimal 8 karakter',
          controller: _passwordController,
          isPassword: true,
          prefixIcon: Icons.lock_outline_rounded,
          errorText: auth.getFieldError('password'),
          validator: (v) => (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Konfirmasi Kata Sandi',
          hint: 'Ulangi kata sandi',
          controller: _confirmPasswordController,
          isPassword: true,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.lock_reset_rounded,
          validator: (v) => (v != _passwordController.text) ? 'Kata sandi tidak cocok' : null,
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: _selectedRole == 'technician' ? 'Daftar Sebagai Teknisi' : 'Daftar Sekarang',
          isLoading: auth.isLoading,
          backgroundColor: _selectedRole == 'technician' ? AppColors.secondary : AppColors.primary,
          onPressed: _handleRegister,
        ),
        const SizedBox(height: 16),
        _buildLoginLink(),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = 'customer'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedRole == 'customer' ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_rounded, size: 18, color: _selectedRole == 'customer' ? AppColors.primary : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Pelanggan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _selectedRole == 'customer' ? AppColors.primary : AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = 'technician'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedRole == 'technician' ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handyman_rounded, size: 18, color: _selectedRole == 'technician' ? AppColors.secondary : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Teknisi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _selectedRole == 'technician' ? AppColors.secondary : AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Sudah punya akun? ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text('Masuk di sini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
      ],
    );
  }
}
