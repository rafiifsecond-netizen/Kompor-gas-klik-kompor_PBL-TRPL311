import 'package:flutter/material.dart';

void main() {
  runApp(const KlikKomporApp());
}

class KlikKomporApp extends StatelessWidget {
  const KlikKomporApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KlikKompor',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF7300),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  final Color orange = const Color(0xFFFF7300);
  final Color inputColor = const Color(0xFFD9D9D9);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 31),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // =========================
                  // LOGO
                  // =========================
                  Image.asset(
                    'assets/images/logo_klikkompor.png',
                    width: 145,
                    height: 145,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 5),

                  // =========================
                  // EMAIL / NOMOR TELEPON
                  // =========================
                  _buildInputField(
                    controller: emailController,
                    hintText: 'Email atau nomor telepon',
                    icon: Icons.mail_outline,
                    obscureText: false,
                  ),

                  const SizedBox(height: 14),

                  // =========================
                  // PASSWORD
                  // =========================
                  _buildInputField(
                    controller: passwordController,
                    hintText: 'Masukkan kata sandi',
                    icon: Icons.lock_outline,
                    obscureText: hidePassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =========================
                  // KONFIRMASI PASSWORD
                  // =========================
                  _buildInputField(
                    controller: confirmPasswordController,
                    hintText: 'Konfirmasi kata sandi',
                    icon: Icons.lock_outline,
                    obscureText: hideConfirmPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hideConfirmPassword = !hideConfirmPassword;
                        });
                      },
                      icon: Icon(
                        hideConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // BUTTON MASUK
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 39,
                    child: ElevatedButton(
                      onPressed: () {
                        _login();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =========================
                  // DAFTAR
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: buka halaman register
                        },
                        child: const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 29),

                  // =========================
                  // ATAU
                  // =========================
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.black54,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'atau',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 29),

                  // =========================
                  // LUPA PASSWORD
                  // =========================
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: buka halaman lupa password
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // INPUT FIELD
  // =========================================================

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 39,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: inputColor,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
          ),
          prefixIcon: Icon(
            icon,
            size: 21,
            color: Colors.black87,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: orange,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LOGIN
  // =========================================================

  void _login() {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showMessage('Semua field harus diisi');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showMessage('Konfirmasi kata sandi tidak sama');
      return;
    }

    _showMessage('Login berhasil');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: orange,
      ),
    );
  }
}
