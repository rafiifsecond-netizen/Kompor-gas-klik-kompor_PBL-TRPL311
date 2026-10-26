import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  int _currentStep = 1; // Step 1: Request token, Step 2: Reset password
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRequestToken() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final result = await auth.forgotPassword(email: _emailCtrl.text.trim());

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _currentStep = 2;
        _tokenCtrl.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode verifikasi telah dikirimkan ke ${_emailCtrl.text.trim()}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(
      email: _emailCtrl.text.trim(),
      token: _tokenCtrl.text.trim(),
      newPassword: _passCtrl.text,
      newPasswordConfirmation: _confirmCtrl.text,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi berhasil diperbarui. Silakan login kembali.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () {
            auth.clearErrors();
            if (_currentStep == 2) {
              setState(() {
                _currentStep = 1;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Lupa Kata Sandi',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // ── Logo Animation ──────────────────────────────
                  const _KlikKomporLogo(),

                  const SizedBox(height: 24),

                  // ── Title & Description ────────────────────────
                  Text(
                    _currentStep == 1 ? 'Pemulihan Akun' : 'Atur Ulang Kata Sandi',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentStep == 1
                        ? 'Masukkan alamat email Anda yang terdaftar untuk menerima kode pemulihan.'
                        : 'Masukkan kode pemulihan yang Anda terima beserta kata sandi baru Anda.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Error Banner ───────────────────────────────
                  if (auth.errorMessage != null) ...[
                    _ErrorBanner(message: auth.errorMessage!),
                    const SizedBox(height: 16),
                  ],

                  // ── Step 1: Input Email ────────────────────────
                  if (_currentStep == 1) ...[
                    _AuthField(
                      controller: _emailCtrl,
                      hint: 'Alamat Email',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      errorText: auth.getFieldError('email'),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Alamat email tidak valid' : null,
                    ),
                    const SizedBox(height: 20),
                    _AuthButton(
                      label: 'Kirim Kode Pemulihan',
                      isLoading: auth.isLoading,
                      onTap: _handleRequestToken,
                    ),
                  ],

                  // ── Step 2: Input Code & New Password ──────────
                  if (_currentStep == 2) ...[
                    // Info Pengiriman Kode Verifikasi
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.mark_email_read_rounded, color: Colors.blue, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Kode Verifikasi Terkirim',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Silakan periksa pesan email atau SMS ke ${_emailCtrl.text.trim()} untuk mendapatkan 6-digit kode verifikasi.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _AuthField(
                      controller: _emailCtrl,
                      hint: 'Alamat Email',
                      icon: Icons.mail_outline_rounded,
                      enabled: false,
                    ),
                    const SizedBox(height: 12),

                    _AuthField(
                      controller: _tokenCtrl,
                      hint: 'Kode Verifikasi (6-digit)',
                      icon: Icons.key_rounded,
                      keyboardType: TextInputType.number,
                      errorText: auth.getFieldError('token'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Kode wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),

                    _AuthField(
                      controller: _passCtrl,
                      hint: 'Kata Sandi Baru (min 8 karakter)',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePass,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black54,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                      errorText: auth.getFieldError('password'),
                      validator: (v) =>
                          (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
                    ),
                    const SizedBox(height: 12),

                    _AuthField(
                      controller: _confirmCtrl,
                      hint: 'Konfirmasi Kata Sandi Baru',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.black54,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
                        if (v != _passCtrl.text) return 'Konfirmasi kata sandi tidak cocok';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    _AuthButton(
                      label: 'Ubah Kata Sandi',
                      isLoading: auth.isLoading,
                      onTap: _handleResetPassword,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Back to Login Link ─────────────────────────
                  GestureDetector(
                    onTap: () {
                      auth.clearErrors();
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: Text(
                      'Kembali ke Halaman Login',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGET HELPERS
// ═════════════════════════════════════════════════════════════════════════════

class _KlikKomporLogo extends StatefulWidget {
  const _KlikKomporLogo();

  @override
  State<_KlikKomporLogo> createState() => _KlikKomporLogoState();
}

class _KlikKomporLogoState extends State<_KlikKomporLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Image.asset(
        'assets/images/logo.png',
        width: 140,
        height: 120,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.danger),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? errorText;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.suffixIcon,
    this.errorText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? const Color(0xFFE8E8E8) : const Color(0xFFF0F0F0),
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, size: 20, color: Colors.black54),
        suffixIcon: suffixIcon,
        errorText: errorText,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.danger),
      ),
      validator: validator,
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
