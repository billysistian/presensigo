import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../menu/menu_screen.dart';
import '../../../utils/toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.post("/employee/login", {
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      });

      const baseUrl = 'https://payroll.gomega.co.id/storage/';

      final token = response["token"];
      final user = response["user"];

      final userName = user?["name"] ?? "User";
      final avatarPath = user?["avatar"];
      final avatarUrl = (avatarPath != null && avatarPath.isNotEmpty)
          ? '$baseUrl$avatarPath'
          : '';
      final email = user?["email"] ?? "";
      final tanggalLahir = user?["birthday"] ?? "";
      final alamat = user?["alamat"] ?? "";
      final role = user?["posisi"] ?? "";

      if (token != null) {
        await AuthService.saveToken(
          token: token,
          userName: userName,
          avatarUrl: avatarUrl,
          email: email,
          tanggalLahir: tanggalLahir,
          alamat: alamat,
          role: role,
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MenuScreen(
              userName: userName,
              avatarUrl: avatarUrl,
              email: email,
              tanggalLahir: tanggalLahir,
              alamat: alamat,
              role: role,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        showModernToast(
          context,
          (response["message"] ?? "Login gagal"),
          success: false,
        );
      }
    } on SocketException {
      // ✅ menangani kalau tidak ada internet
      if (!mounted) return;
      showModernToast(
        context,
        "Tidak ada koneksi internet!",
        success: false,
      );
    } catch (e) {
      if (!mounted) return;
      showModernToast(
        context,
        "Terjadi kesalahan: $e",
        success: false,
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // === BACKGROUND BULATAN BLUR ===
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF4FF),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            right: -120,
            child: Container(
              width: 380,
              height: 380,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF4FF),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // === MAIN LOGIN CONTENT ===
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

                    // TITLE IMAGE
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0369A1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(
                          'assets/icon/foreground_icon.png',
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Center(
                      child: Text(
                        "Welcome back you've\nbeen missed!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // EMAIL FIELD
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF0284C7), width: 1.8),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Email wajib diisi" : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD FIELD
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Password",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          border: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: Color(0xFF0284C7), width: 1.8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Password wajib diisi" : null,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // BUTTON LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0369A1),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          // ignore: deprecated_member_use
                          shadowColor: const Color(0xFF0284C7).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Sign in",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
