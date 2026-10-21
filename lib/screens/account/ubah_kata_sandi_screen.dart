import 'package:flutter/material.dart';
import '../../../services/api_client.dart';

class UbahKataSandiScreen extends StatefulWidget {
  const UbahKataSandiScreen({super.key});

  @override
  State<UbahKataSandiScreen> createState() => _UbahKataSandiScreenState();
}

class _UbahKataSandiScreenState extends State<UbahKataSandiScreen> {
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  Future<void> _ubahPassword() async {
    final current = _currentPassController.text.trim();
    final baru = _newPassController.text.trim();
    final konfirmasi = _confirmPassController.text.trim();

    if (current.isEmpty || baru.isEmpty || konfirmasi.isEmpty) {
      _showDialog("Gagal", "Semua field wajib diisi!");
      return;
    }

    if (baru != konfirmasi) {
      _showDialog("Gagal", "Konfirmasi password tidak cocok!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.post('/employee/change-password', {
        "current_password": current,
        "new_password": baru,
        "new_password_confirmation": konfirmasi,
      });

      if (res['success'] == true) {
        if (!mounted) return;

        _showDialog("Berhasil", "Kata sandi berhasil diperbarui!");

        _currentPassController.clear();
        _newPassController.clear();
        _confirmPassController.clear();

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/menu');
        });
      } else {
        if (!mounted) return;
        _showDialog("Gagal", res['message'] ?? "Terjadi kesalahan");
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog("Error", "Gagal mengubah kata sandi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isSuccess = title.toLowerCase().contains('berhasil');

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔵 Ikon status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error_outline,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Judul dialog
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                const SizedBox(height: 10),

                // Pesan
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // Tombol OK
                isSuccess
                    ? const SizedBox.shrink() // Tidak tampilkan tombol
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF163A56)),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          "Ubah Kata Sandi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF163A56),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset("assets/images/lock.png", height: 180),
                const SizedBox(height: 30),
                _buildPasswordField(
                  controller: _currentPassController,
                  label: "Password saat ini",
                  obscureText: _obscureCurrent,
                  onToggle: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(
                        color: Color.fromRGBO(25, 118, 210, 1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                _buildPasswordField(
                  controller: _newPassController,
                  label: "Password baru",
                  obscureText: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmPassController,
                  label: "Konfirmasi password baru",
                  obscureText: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 4,
              ),
              onPressed: _isLoading ? null : _ubahPassword,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Simpan Perubahan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.black54),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF163A56),
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
