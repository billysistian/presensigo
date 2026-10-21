import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../services/auth_service.dart';
import '../login/login_screen.dart';
import 'detail_personal_screen.dart';
import 'ubah_kata_sandi_screen.dart';
import 'language_selection_screen.dart';

class AccountScreen extends StatefulWidget {
  final String userName;
  final String? role;
  final String? avatarUrl;
  final String? email;
  final String? tanggalLahir;
  final String? alamat;

  const AccountScreen({
    super.key,
    required this.userName,
    this.role,
    this.avatarUrl,
    this.email,
    this.tanggalLahir,
    this.alamat,
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _appVersion = '';
  String userName = '';
  String? role;
  String? avatarUrl;
  String? email;
  String? tanggalLahir;
  String? alamat;
  bool _reminderOn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVersion();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    final userRole = await AuthService.getRole();
    setState(() {
      userName = userData["user_name"] ?? widget.userName;
      avatarUrl = userData["avatar_url"] ?? widget.avatarUrl;
      email = userData["email"] ?? widget.email;
      tanggalLahir = userData["tanggal_lahir"] ?? widget.tanggalLahir;
      alamat = userData["alamat"] ?? widget.alamat;
      role = userRole ?? widget.role;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  void _showChangeLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Ganti Bahasa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.indigo,
            ),
          ),
          content: const Text(
            'Apa anda yakin ingin mengganti bahasa aplikasi Presensi?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LanguageSelectionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Ya',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Batalkan',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Peringatan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF163A56),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Anda yakin ingin keluar?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Keluar (Biru)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2485DA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _logout();
                    },
                    child: const Text(
                      "Keluar",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Tombol Batalkan (Outline)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2485DA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Batalkan",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF2485DA),
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

  Widget _rowItem({
    required String iconPath,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            trailing ??
                Image.asset(
                  'assets/icon/arrow-right.png', // path gambar kamu
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0xFFEAEAEA));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Akun',
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF163A56),
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF163A56)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          (avatarUrl != null && avatarUrl!.isNotEmpty)
                              ? NetworkImage(
                                  avatarUrl!.startsWith('http')
                                      ? avatarUrl!
                                      : 'https://payroll.gomega.co.id/storage/$avatarUrl',
                                )
                              : null,
                      child: (avatarUrl == null || avatarUrl!.isEmpty)
                          ? const Icon(Icons.person,
                              color: Color(0xFF2485DA), size: 32)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF163A56),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role ?? 'Administrasi',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF9AA7B6)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Section: Data Pribadi
                const Text(
                  'Data Pribadi',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF163A56)),
                ),
                const SizedBox(height: 14),
                _rowItem(
                  iconPath: 'assets/icon/profile.png',
                  title: 'Info Pribadi',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPersonalScreen(
                          userName: userName,
                          avatarUrl: avatarUrl,
                          email: email,
                          tanggalLahir: tanggalLahir,
                          alamat: alamat,
                        ),
                      ),
                    );

                    // ✅ Refresh ulang data dari SharedPreferences setelah balik
                    await _loadUserData();
                  },
                ),
                _divider(),
                _rowItem(
                  iconPath: 'assets/icon/lock.png',
                  title: 'Ubah Kata Sandi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const UbahKataSandiScreen()),
                    );
                  },
                ),
                _divider(),

                const SizedBox(height: 28),

                // Section: Pengaturan Presensi
                const Text(
                  'Pengaturan Presensi',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF163A56)),
                ),
                const SizedBox(height: 14),
                _rowItem(
                  iconPath: 'assets/icon/more.png',
                  title: 'Ganti Bahasa',
                  onTap: () => _showChangeLanguageDialog(context),
                ),
                _divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icon/notification.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              'Notifikasi Reminder',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Center(
                                child: Text(
                                  '?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF163A56),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SwitchTheme(
                        data: SwitchThemeData(
                          trackOutlineColor:
                              WidgetStateProperty.all(Colors.transparent),
                          trackOutlineWidth: WidgetStateProperty.all(0),
                        ),
                        child: Switch.adaptive(
                          value: _reminderOn,
                          inactiveTrackColor: Colors.grey[200],
                          inactiveThumbColor: Colors.white,
                          activeColor: const Color(0xFF2485DA),
                          onChanged: (v) => setState(() => _reminderOn = v),
                        ),
                      ),
                    ],
                  ),
                ),
                _divider(),

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    'Versi Aplikasi $_appVersion',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF163A56),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),

      // Tombol logout di bawah
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              _showLogoutDialog();
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFEBEEF1)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              elevation: 0,
            ),
            child: const Text(
              'Keluar Akun',
              style: TextStyle(
                  color: Color(0xFF163A56),
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
