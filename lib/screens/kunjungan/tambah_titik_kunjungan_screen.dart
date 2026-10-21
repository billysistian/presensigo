import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/api_client.dart';
import '../../utils/toast.dart';
import '../../utils/tanggal_indo.dart';
import '../../widgets/jam_wib_widget.dart';

class TambahTitikKunjunganScreen extends StatefulWidget {
  const TambahTitikKunjunganScreen({super.key});

  @override
  State<TambahTitikKunjunganScreen> createState() =>
      _TambahTitikKunjunganScreenState();
}

class _TambahTitikKunjunganScreenState
    extends State<TambahTitikKunjunganScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noTelephoneController = TextEditingController();

  final MapController _mapController = MapController();
  LatLng _selectedPosition = const LatLng(-6.200000, 106.816666);
  bool isLoadingLocation = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Tunggu widget selesai di-render baru ambil lokasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _noTelephoneController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => isLoadingLocation = false);
        if (!mounted) return;
        showModernToast(context, 'Layanan lokasi tidak aktif', success: false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => isLoadingLocation = false);
          if (!mounted) return;
          showModernToast(context, 'Izin lokasi ditolak', success: false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => isLoadingLocation = false);
        if (!mounted) return;
        showModernToast(context, 'Izin lokasi ditolak permanen',
            success: false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
        isLoadingLocation = false;
      });

      // Tunggu sebentar biar map sudah benar-benar render
      await Future.delayed(const Duration(milliseconds: 500));

      // Move camera ke lokasi user
      if (mounted) {
        try {
          _mapController.move(_selectedPosition, 16);
        } catch (e) {
          debugPrint('Map controller belum siap: $e');
        }
      }
    } catch (e) {
      debugPrint('Error mendapatkan lokasi: $e');
      if (!mounted) return;
      setState(() => isLoadingLocation = false);
      showModernToast(context, 'Gagal mendapatkan lokasi', success: false);
    }
  }

  Future<void> _simpanTitikKunjungan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final data = {
        "pelanggan": _namaController.text.trim(),
        "alamat": _alamatController.text.trim(),
        "no_telephone": _noTelephoneController.text.trim().isEmpty
            ? null
            : _noTelephoneController.text.trim(),
        "latitude": _selectedPosition.latitude,
        "longitude": _selectedPosition.longitude,
      };

      await ApiClient.post("/add-outlet", data);

      if (!mounted) return;
      showModernToast(context, 'Titik kunjungan berhasil ditambahkan',
          success: true);
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error simpan titik kunjungan: $e');
      if (!mounted) return;
      showModernToast(context, 'Gagal menambahkan titik kunjungan',
          success: false);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final double mapHeight = isKeyboardVisible ? 160 : 260;
    final double sheetTop = mapHeight - 30.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF163A56)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Titik Kunjungan',
          style: TextStyle(
            color: Color(0xFF163A56),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF163A56)),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // === MAP ===
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: mapHeight,
              curve: Curves.easeInOut,
              child: isLoadingLocation
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                      ),
                    )
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedPosition,
                        initialZoom: 16,
                        onTap: (tapPosition, point) {
                          setState(() => _selectedPosition = point);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.presensigac.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPosition,
                              width: 40,
                              height: 40,
                              child: Image.asset(
                                'assets/icon/marker.png',
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
            ),
          ),

          // === SHEET (HEADER) ===
          Positioned(
            top: sheetTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatBulan(DateTime.now().toIso8601String()),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const JamWibWidget(),
                    ],
                  ),
                ),

                // === FORM (WHITE SHEET) ===
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildInput(_namaController, "Nama Titik/Outlet",
                                required: true),
                            const SizedBox(height: 12),
                            _buildInput(_alamatController,
                                "Alamat Titik/Outlet (Optional)",
                                maxLines: 2),
                            const SizedBox(height: 12),
                            _buildInput(_noTelephoneController,
                                "No Telephone (Optional)",
                                keyboard: TextInputType.phone),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // === BUTTON FLOATING ===
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _simpanTitikKunjungan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2485DA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Tambah Titik Kunjungan",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String hint,
      {bool required = false,
      int maxLines = 1,
      TextInputType keyboard = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: required
            ? (v) =>
                (v == null || v.trim().isEmpty) ? '$hint wajib diisi' : null
            : null,
      ),
    );
  }
}
