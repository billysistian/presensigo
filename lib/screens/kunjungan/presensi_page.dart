import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'kunjungan_presensi_screen.dart';
import '../../services/api_client.dart';
import '../../utils/toast.dart';
import '../../utils/fake_gps_dialog.dart';
import '../../utils/selfie_camera_screen.dart';
import '../../utils/tanggal_indo.dart';
import '../../widgets/jam_wib_widget.dart';

class PresensiPage extends StatefulWidget {
  final Map<String, dynamic> outlet;
  const PresensiPage({Key? key, required this.outlet}) : super(key: key);

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  Position? _currentPosition;
  File? _selfieImage;
  bool _loading = false;
  final TextEditingController _catatanController = TextEditingController();
  final MapController _mapController = MapController();

  static const double maxDistanceKm = 0.05;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        showModernToast(context, 'Aktifkan layanan lokasi di perangkat Anda',
            success: false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          showModernToast(context, 'Izin lokasi ditolak', success: false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        showModernToast(
          context,
          'Izin lokasi ditolak permanen. Buka pengaturan untuk mengizinkan.',
          success: false,
        );
        return;
      }

      StreamSubscription<Position>? positionStream;

      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).listen((Position position) {
        if (position.isMocked) {
          positionStream?.cancel();
          if (!mounted) return;
          FakeGpsDialog.show(
            context: context,
            onConfirmed: () {
              Future.delayed(const Duration(seconds: 3), () {
                _getCurrentLocation();
              });
            },
          );
          return;
        }

        positionStream?.cancel();
        setState(() => _currentPosition = position);
        _mapController.move(LatLng(position.latitude, position.longitude), 17);
        if (!mounted) return;
        showModernToast(context, 'Lokasi berhasil diperbarui', success: true);
      });

      Future.delayed(const Duration(seconds: 15), () {
        positionStream?.cancel();
        if (_currentPosition == null) {
          if (!mounted) return;
          showModernToast(context, 'Gagal mendapatkan lokasi, coba lagi',
              success: false);
        }
      });
    } catch (e) {
      if (!mounted) return;
      showModernToast(context, 'Gagal mendapatkan lokasi: $e', success: false);
    }
  }

  Future<void> _ambilFotoSelfie() async {
    final File? foto = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelfieCameraScreen()),
    );

    if (foto != null) {
      setState(() => _selfieImage = foto);
    }
  }

  double _getDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> _absenKunjungan() async {
    if (_currentPosition == null) {
      showModernToast(context, 'Lokasi belum ditemukan', success: false);
      return;
    }

    if (_selfieImage == null) {
      showModernToast(context, 'Foto selfie belum diambil', success: false);
      return;
    }

    final outletLat =
        double.tryParse(widget.outlet['latitude'].toString()) ?? 0;
    final outletLng =
        double.tryParse(widget.outlet['longitude'].toString()) ?? 0;
    final distance = _getDistanceKm(
      outletLat,
      outletLng,
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    if (distance > maxDistanceKm) {
      showModernToast(context, 'Lokasi Anda tidak sesuai dengan lokasi outlet',
          success: false);
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await ApiClient.postMultipart(
        '/absen',
        fields: {
          'outlet_id': widget.outlet['id'].toString(),
          'latitude': _currentPosition!.latitude.toString(),
          'longitude': _currentPosition!.longitude.toString(),
          'catatan': _catatanController.text,
        },
        files: [
          {'field': 'foto', 'file': _selfieImage!},
        ],
      );

      final responseBody = await response.stream.bytesToString();

      debugPrint('DEBUG: status code: ${response.statusCode}');
      debugPrint('DEBUG: response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        showModernToast(context, 'Presensi berhasil!', success: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const KunjunganPresensiScreen()),
          (route) => route.isFirst,
        );
      } else if (response.statusCode == 409) {
        if (!mounted) return;
        showModernToast(context, 'Anda sudah absen untuk outlet ini hari ini.',
            success: false);
      } else {
        if (!mounted) return;
        showModernToast(context, 'Gagal melakukan presensi', success: false);
      }
    } catch (e) {
      if (!mounted) return;
      showModernToast(context, 'Terjadi kesalahan: $e', success: false);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final outletLat =
        double.tryParse(widget.outlet['latitude'].toString()) ?? 0;
    final outletLng =
        double.tryParse(widget.outlet['longitude'].toString()) ?? 0;
    final outletPos = LatLng(outletLat, outletLng);

    if (outletLat == 0 && outletLng == 0) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Absen Kunjungan'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              const Text(
                'Data outlet tidak valid!',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
            'Absen Kunjungan',
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
                  _currentPosition == null
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
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            initialZoom: 18,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.presensigac.app',
                            ),
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: outletPos,
                                  color: const Color(0xFF0EA5E9)
                                      .withValues(alpha: 0.15),
                                  borderStrokeWidth: 2.5,
                                  borderColor: const Color(0xFF0284C7),
                                  radius: maxDistanceKm * 1000,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 38,
                                  height: 38,
                                  point: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  child: Image.asset(
                                    'assets/icon/marker.png',
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                                Marker(
                                  width: 38,
                                  height: 38,
                                  point: outletPos,
                                  child: Image.asset(
                                    'assets/icon/location-outline.png',
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ],
                            ),
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag Handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

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
                                              colors: [
                                                Color(0xFF0EA5E9),
                                                Color(0xFF0284C7)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                              if (_selfieImage == null)
                                _buildPhotoPlaceholderSmall()
                              else
                                _buildPhotoPreviewSmall(),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // CATATAN SECTION
                          _buildSectionHeader(
                            icon: 'assets/icon/note.png',
                            title: 'Catatan Kunjungan',
                            subtitle: 'Opsional',
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _catatanController,
                            maxLines: 4,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Tulis catatan kunjungan Anda di sini...',
                              hintStyle: TextStyle(
                                color: const Color(0xFF64748B)
                                    .withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.all(16),
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
                          ),

                          const SizedBox(height: 100),
                        ],
                      ),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _absenKunjungan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Absen Sekarang',
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
      onTap: _ambilFotoSelfie,
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
              _selfieImage!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: _ambilFotoSelfie,
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
