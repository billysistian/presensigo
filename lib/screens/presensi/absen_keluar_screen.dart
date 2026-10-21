import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../services/api_client.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/selfie_camera_screen.dart';
import '../../utils/tanggal_indo.dart';
import '../../widgets/jam_wib_widget.dart';

class AbsenKeluarScreen extends StatefulWidget {
  const AbsenKeluarScreen({super.key});

  @override
  State<AbsenKeluarScreen> createState() => _AbsenKeluarScreenState();
}

class _AbsenKeluarScreenState extends State<AbsenKeluarScreen>
    with TickerProviderStateMixin {
  int selectedTab = 0;
  File? selfieImage;
  bool loading = false;

  List<Map<String, dynamic>> lokasiList = [];
  Map<String, dynamic>? lokasiAktif;
  Position? posisiSekarang;

  final TextEditingController catatanController = TextEditingController();
  final MapController _mapController = MapController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _ambilLokasiSekarang();
    _fetchLokasi();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  Future<void> _ambilLokasiSekarang() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showDialog("GPS Nonaktif", "Aktifkan layanan lokasi terlebih dahulu.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      _showDialog("Izin Lokasi Ditolak", "Izin lokasi permanen ditolak.");
      return;
    }

    Position posisi = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (posisi.isMocked) {
      _showDialog(
          "Peringatan", "Deteksi fake GPS aktif. Mohon nonaktifkan GPS palsu.");
      return;
    }

    posisiSekarang = posisi;
    setState(() {});
    _mapController.move(LatLng(posisi.latitude, posisi.longitude), 18);
  }

  Future<void> _fetchLokasi() async {
    try {
      final res = await ApiClient.get('/lokasi-presensi');
      if (res is List) {
        setState(() {
          lokasiList = List<Map<String, dynamic>>.from(res.map((lok) => {
                "id": lok["id"],
                "nama": lok["nama_lokasi"],
                "alamat": lok["alamat_lokasi"],
                "latitude": double.tryParse(lok["latitude"].toString()) ?? 0.0,
                "longitude":
                    double.tryParse(lok["longitude"].toString()) ?? 0.0,
                "radius": double.tryParse(lok["radius"].toString()) ?? 0.0,
              }));
          if (lokasiList.isNotEmpty) lokasiAktif = lokasiList.first;
        });
      }
    } catch (e) {
      debugPrint("❌ Gagal ambil lokasi: $e");
    }
  }

  Future<void> _ambilSelfie() async {
    final File? foto = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelfieCameraScreen()),
    );

    if (foto != null) {
      setState(() => selfieImage = foto);
    }
  }

  double _hitungJarak(double lat1, double lon1, double lat2, double lon2) {
    const Distance distance = Distance();
    return distance.as(
        LengthUnit.Meter, LatLng(lat1, lon1), LatLng(lat2, lon2));
  }

  Future<void> _absenKeluar() async {
    if (lokasiAktif == null) {
      _showDialog("Gagal", "Lokasi belum dimuat.");
      return;
    }
    if (selfieImage == null) {
      _showDialog("Gagal", "Ambil foto selfie terlebih dahulu.");
      return;
    }
    if (posisiSekarang == null) {
      _showDialog("Gagal", "Lokasi GPS belum ditemukan.");
      return;
    }

    final jarak = _hitungJarak(
      posisiSekarang!.latitude,
      posisiSekarang!.longitude,
      lokasiAktif!["latitude"],
      lokasiAktif!["longitude"],
    );

    final radius = lokasiAktif!["radius"];
    if (jarak > radius) {
      _showDialog("Gagal",
          "Anda berada di luar radius lokasi. (${jarak.toStringAsFixed(1)} m dari lokasi)");
      return;
    }

    setState(() => loading = true);
    try {
      final res = await ApiClient.postMultipart(
        '/presensi/pulang',
        fields: {
          "latitude": posisiSekarang!.latitude.toString(),
          "longitude": posisiSekarang!.longitude.toString(),
          "catatan": catatanController.text,
        },
        files: [
          {"field": "foto_keluar", "file": selfieImage!}
        ],
      );

      final body = await res.stream.bytesToString();
      debugPrint("✅ PRESENSI KELUAR RESPONSE: $body");

      if (res.statusCode == 200) {
        _showDialog("Berhasil", "Presensi keluar berhasil disimpan!");

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;

          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
        });
      } else if (res.statusCode == 404) {
        _showDialog("Gagal", "Belum absen masuk!");
      } else if (res.statusCode == 409) {
        _showDialog("Gagal", "Sudah absen pulang!");
      } else {
        _showDialog("Gagal", "Presensi keluar gagal. Coba lagi nanti.");
      }
    } catch (e) {
      _showDialog("Error", e.toString());
    } finally {
      setState(() => loading = false);
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSuccess
                    ? [Colors.white, const Color(0xFFF0FDF4)]
                    : [Colors.white, const Color(0xFFFEF2F2)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isSuccess ? Colors.green : Colors.red)
                      .withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSuccess
                          ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                          : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSuccess
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444))
                            .withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSuccess
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSuccess
                          ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                          : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isSuccess
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444))
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "OK",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final double mapHeight = isKeyboardVisible ? 160 : 280;
    final double sheetTop = mapHeight - 30.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Text(
            'Absen Keluar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF0F172A),
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF0F172A),
                size: 20,
              ),
            ),
            onPressed: () {
              _fetchLokasi();
              _ambilLokasiSekarang();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // MAP SECTION
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: mapHeight,
              curve: Curves.easeInOut,
              child: Stack(
                children: [
                  posisiSekarang == null
                      ? Shimmer.fromColors(
                          baseColor: const Color(0xFFE2E8F0),
                          highlightColor: const Color(0xFFF1F5F9),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        )
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              posisiSekarang!.latitude,
                              posisiSekarang!.longitude,
                            ),
                            initialZoom: 18,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              userAgentPackageName: 'com.presensigac.app',
                            ),
                            if (lokasiAktif != null)
                              CircleLayer(circles: [
                                CircleMarker(
                                  point: LatLng(
                                    lokasiAktif!['latitude'],
                                    lokasiAktif!['longitude'],
                                  ),
                                  color: const Color(0xFF0EA5E9)
                                      .withValues(alpha: 0.15),
                                  borderStrokeWidth: 2.5,
                                  borderColor: const Color(0xFF0284C7),
                                  radius: lokasiAktif!['radius'],
                                ),
                              ]),
                            MarkerLayer(markers: [
                              Marker(
                                point: LatLng(
                                  posisiSekarang!.latitude,
                                  posisiSekarang!.longitude,
                                ),
                                width: 38,
                                height: 38,
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale:
                                          1.0 + (_pulseController.value * 0.1),
                                      child: child,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/icon/marker.png',
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),

                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFF8FAFC).withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CONTENT SHEET
          Positioned(
            top: sheetTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Date & Time Header
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatBulan(DateTime.now().toIso8601String()),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const JamWibWidget(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Form Container
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Drag Handle
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        // Tab Navigation
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildTabItem("Lokasi", Icons.location_on, 0),
                              _buildTabItem("Lampiran", Icons.attach_file, 1),
                            ],
                          ),
                        ),

                        // Tab Content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 100,
                            ),
                            child: IndexedStack(
                              index: selectedTab,
                              children: [
                                _buildLokasiTab(),
                                _buildLampiranTab(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FLOATING BUTTON
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: loading
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  boxShadow: loading
                      ? null
                      : [
                          BoxShadow(
                            color:
                                const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: ElevatedButton(
                  onPressed: loading ? null : _absenKeluar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        loading ? const Color(0xFFE2E8F0) : Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Color(0xFF0284C7),
                            strokeWidth: 3,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fingerprint,
                                color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Absen Keluar Sekarang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
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
    );
  }

  Widget _buildTabItem(String label, IconData icon, int index) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLokasiTab() {
    return Column(
      children: lokasiList.map((lokasi) {
        final selected = lokasiAktif?['id'] == lokasi['id'];
        return GestureDetector(
          onTap: () => setState(() => lokasiAktif = lokasi),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE0F2FE) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? const Color(0xFF0EA5E9)
                    : const Color(0xFFE2E8F0),
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: selected
                          ? [const Color(0xFF0EA5E9), const Color(0xFF0284C7)]
                          : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: selected ? Colors.white : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lokasi['nama'],
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: selected
                              ? const Color(0xFF0369A1)
                              : const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lokasi['alamat'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLampiranTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FOTO SELFIE SECTION
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/icon/camera-selfie.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Foto Selfie',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Ambil foto untuk verifikasi',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (selfieImage == null)
              _buildPhotoPlaceholderSmall()
            else
              _buildPhotoPreviewSmall(),
          ],
        ),

        const SizedBox(height: 24),

        // CATATAN SECTION
        _buildSectionHeader(
          icon: 'assets/icon/note.png',
          title: 'Catatan Presensi',
          subtitle: 'Opsional',
        ),
        const SizedBox(height: 16),

        TextField(
          controller: catatanController,
          maxLines: 4,
          maxLength: 150,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: 'Tulis catatan di sini...',
            hintStyle: TextStyle(
              color: const Color(0xFF64748B).withValues(alpha: 0.6),
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(16),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF0EA5E9),
                width: 2,
              ),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              "${catatanController.text.length}/150",
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            icon,
            width: 20,
            height: 20,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholderSmall() {
    return InkWell(
      onTap: _ambilSelfie,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    const Color(0xFF0284C7).withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ambil',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreviewSmall() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.file(
              selfieImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: _ambilSelfie,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.refresh,
                size: 14,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ],
    );
  }
}
