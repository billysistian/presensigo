import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_client.dart';
import '../../../utils/toast.dart';
import '../../../utils/modal_riwayat_absen.dart';
import '../../../utils/update_checker.dart';

import '../presensi/absen_masuk_screen.dart';
import '../presensi/absen_keluar_screen.dart';
import '../kunjungan/kunjungan_presensi_screen.dart';
import '../account/account_screen.dart';
import '../programs/program_detail_screen.dart';
import '../salary/salary_slip_screen.dart';
import '../programs/list_program_screen.dart';
import '../overtime_list_screen.dart';
import '../kasbon_list_screen.dart';
import '../reimburse_list_screen.dart';
import '../leave_list_screen.dart';

class MenuScreen extends StatefulWidget {
  final String userName;
  final String? role;
  final String? avatarUrl;
  final String? email;
  final String? tanggalLahir;
  final String? alamat;

  const MenuScreen({
    super.key,
    required this.userName,
    this.role,
    this.avatarUrl,
    this.email,
    this.tanggalLahir,
    this.alamat,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  DateTime currentTime = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  AnimationController? _fadeController;
  AnimationController? _slideController;

  // Data profil
  String userName = "";
  String? avatarUrl;
  String? email;
  String? tanggalLahir;
  String? alamat;
  String? role;
  String? bannerImage;
  String? bannerTitle;
  String? bannerDescription;
  String? startDate;
  String? endDate;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loadUserData();
    _startClock();
    loadBanner();

    _fadeController?.forward();
    _slideController?.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateChecker.checkForUpdate(context);
    });
  }

  Future<void> loadBanner() async {
    try {
      final response = await ApiClient.get("/programs");

      if (response is Map && response["data"] is List) {
        final list = response["data"] as List;

        setState(() {
          if (list.isNotEmpty) {
            final banner = list.first;
            bannerImage = banner["image"];
            bannerTitle = banner["title"];
            bannerDescription = banner["description"];
            startDate = banner["start_date"] ?? "-";
            endDate = banner["end_date"] ?? "-";
          } else {
            bannerImage = null;
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal load banner: $e");
    }
  }

  Future<void> _loadUserData() async {
    final data = await AuthService.getUserData();
    final userRole = await AuthService.getRole();
    if (!mounted) return;
    setState(() {
      userName = data['user_name'] ?? widget.userName;
      avatarUrl = data['avatar_url'] ?? widget.avatarUrl;
      email = data['email'] ?? widget.email;
      tanggalLahir = data['tanggal_lahir'] ?? widget.tanggalLahir;
      alamat = data['alamat'] ?? widget.alamat;
      role = userRole ?? widget.role;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController?.dispose();
    _slideController?.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    await _loadUserData();
    await loadBanner();
    setState(() {
      currentTime = DateTime.now();
    });
  }

  void _startClock() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => currentTime = DateTime.now());
        _startClock();
      }
    });
  }

  Widget _menuItem(String iconPath, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.all(5),
            child: Image.asset(
              iconPath,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF163A56)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(currentTime);
    final dateStr =
        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(currentTime);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background gradient
          Container(
            height: 380,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0EA5E9),
                  Color(0xFF0284C7),
                  Color(0xFF0369A1),
                ],
              ),
            ),
          ),

          // Animated circles
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.03),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Header
                FadeTransition(
                  opacity: _fadeController ?? const AlwaysStoppedAnimation(1.0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AccountScreen(
                                  userName: userName,
                                  avatarUrl: avatarUrl,
                                  email: email,
                                  tanggalLahir: tanggalLahir,
                                  alamat: alamat,
                                ),
                              ),
                            ).then((_) {
                              _loadUserData();
                              loadBanner();
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors.white,
                                  backgroundImage: (avatarUrl != null &&
                                          avatarUrl!.isNotEmpty)
                                      ? NetworkImage(
                                          avatarUrl!.startsWith('http')
                                              ? avatarUrl!
                                              : 'https://payroll.gomega.co.id/storage/${avatarUrl!}',
                                        )
                                      : null,
                                  child:
                                      (avatarUrl == null || avatarUrl!.isEmpty)
                                          ? const Icon(Icons.person,
                                              color: Color(0xFF0EA5E9),
                                              size: 28)
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      role ?? '-',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Colors.white, size: 26),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Greeting Section
                FadeTransition(
                  opacity: _fadeController ?? const AlwaysStoppedAnimation(1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${userName.split(' ')[0]}! 👋',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Semangat bekerja hari ini',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Content Container
                Expanded(
                  child: SlideTransition(
                    position: _slideController != null
                        ? Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController!,
                            curve: Curves.easeOutCubic,
                          ))
                        : const AlwaysStoppedAnimation(Offset.zero),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: const Color(0xFF0EA5E9),
                        backgroundColor: Colors.white,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Modern Attendance Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Color(0xFFFAFBFC),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0EA5E9)
                                          .withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFFE0F2FE),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              timeStr,
                                              style: GoogleFonts.inter(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF0F172A),
                                                height: 1,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            Transform.translate(
                                              offset: const Offset(
                                                  0, -6), // naik 4px
                                              child: Text(
                                                'WIB',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF64748B),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.more_horiz_rounded,
                                              color: Color(0xFF475569),
                                            ),
                                            onPressed: () async {
                                              final data =
                                                  await fetchRiwayatData();
                                              if (!context.mounted) return;
                                              showRiwayatModal(
                                                context,
                                                masuk: data['masuk'],
                                                keluar: data['keluar'],
                                                hadir: data['hadir'],
                                                izin: data['izin'],
                                                absen: data['absen'],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      dateStr,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Builder(
                                            builder: (ctx) => Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFF0EA5E9),
                                                    Color(0xFF0284C7),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF0EA5E9)
                                                            .withValues(
                                                                alpha: 0.4),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  try {
                                                    final response =
                                                        await ApiClient.get(
                                                            "/cek-absen-masuk");
                                                    if (!ctx.mounted) return;

                                                    if (response[
                                                            'sudahAbsenMasuk'] ==
                                                        true) {
                                                      showModernToast(
                                                        ctx,
                                                        'Anda sudah absen masuk',
                                                        success: false,
                                                      );
                                                    } else {
                                                      Navigator.push(
                                                        ctx,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                const AbsenMasukScreen()),
                                                      ).then(
                                                          (_) => loadBanner());
                                                    }
                                                  } catch (e) {
                                                    if (!ctx.mounted) return;
                                                    showModernToast(
                                                      ctx,
                                                      'Gagal memeriksa status absen',
                                                      success: false,
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  foregroundColor: Colors.white,
                                                  shadowColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.login_rounded,
                                                        size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Masuk',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Builder(
                                            builder: (ctx) => Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFF0EA5E9),
                                                  width: 2,
                                                ),
                                              ),
                                              child: OutlinedButton(
                                                onPressed: () async {
                                                  try {
                                                    final response =
                                                        await ApiClient.get(
                                                            "/cek-absen-masuk");

                                                    if (!ctx.mounted) return;

                                                    if (response[
                                                            'sudahAbsenMasuk'] !=
                                                        true) {
                                                      showModernToast(
                                                        ctx,
                                                        'Anda belum absen masuk',
                                                        success: false,
                                                      );
                                                    } else {
                                                      Navigator.push(
                                                        ctx,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                const AbsenKeluarScreen()),
                                                      ).then(
                                                          (_) => loadBanner());
                                                    }
                                                  } catch (e) {
                                                    if (!ctx.mounted) return;
                                                    showModernToast(
                                                      ctx,
                                                      'Gagal memeriksa status absen',
                                                      success: false,
                                                    );
                                                  }
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      const Color(0xFF0EA5E9),
                                                  side: BorderSide.none,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons.logout_rounded,
                                                        size: 20),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      'Keluar',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              GridView.count(
                                crossAxisCount: 4,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.88,
                                children: [
                                  _menuItem('assets/icon/document.png',
                                      'Laporan\nPresensi', () {}),
                                  _menuItem('assets/icon/marker.png',
                                      'Kunjungan\nPresensi', () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const KunjunganPresensiScreen()),
                                    ).then((_) => loadBanner());
                                  }),
                                  _menuItem(
                                      'assets/icon/wallet.png', 'Slip\nGaji',
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const SalarySlipScreen()),
                                    );
                                  }),
                                  _menuItem('assets/icon/klaim-beban.png',
                                      'Klaim\nReimburse', () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ReimburseListScreen()),
                                    );
                                  }),
                                  _menuItem(
                                      'assets/icon/task.png', 'Tugas', () {}),
                                  _menuItem('assets/icon/time.png', 'Lembur',
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const OvertimeListScreen()),
                                    );
                                  }),
                                  _menuItem(
                                      'assets/icon/lampiran.png', 'Izin/Cuti',
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const LeaveListScreen()),
                                    );
                                  }),
                                  _menuItem('assets/icon/paper.png', 'Kasbon',
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const KasbonListScreen()),
                                    );
                                  }),
                                ],
                              ),

                              if (bannerImage != null) ...[
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Program Spesial",
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ListProgramScreen(),
                                          ),
                                        ).then((_) => loadBanner());
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Lihat Semua",
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF0284C7),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16,
                                              color: Color(0xFF0284C7),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProgramDetailScreen(
                                          title: bannerTitle ?? "-",
                                          image: bannerImage ?? "",
                                          description: bannerDescription ?? "-",
                                          startDate: startDate ?? "-",
                                          endDate: endDate ?? "-",
                                        ),
                                      ),
                                    ).then((_) => loadBanner());
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF0EA5E9)
                                              .withValues(alpha: 0.15),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            bannerImage!.startsWith('http')
                                                ? bannerImage!
                                                : "https://payroll.gomega.co.id/storage/$bannerImage",
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              color: const Color(0xFFF1F5F9),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image_rounded,
                                                  size: 60,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Gradient overlay
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black
                                                      .withValues(alpha: 0.7),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Content overlay
                                          Positioned(
                                            bottom: 16,
                                            left: 16,
                                            right: 16,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (bannerTitle != null)
                                                  Text(
                                                    bannerTitle!,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                if (startDate != null &&
                                                    endDate != null) ...[
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.25),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .calendar_today_rounded,
                                                          size: 12,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        Text(
                                                          '$startDate - $endDate',
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
