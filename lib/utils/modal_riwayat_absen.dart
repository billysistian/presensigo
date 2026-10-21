import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../../utils/tanggal_indo.dart';

bool _isRiwayatModalOpen = false;

Future<Map<String, dynamic>> fetchRiwayatData() async {
  final hariIniResponse = await ApiClient.get("/presensi/hari-ini");
  final hariIniData = hariIniResponse?['data'] ?? hariIniResponse;

  final masuk = hariIniData?['masuk'];
  final keluar = hariIniData?['keluar'];

  final bulanIniResponse = await ApiClient.get("/presensi/rekap-bulan");
  final bulanIniData = bulanIniResponse?['data'] ?? bulanIniResponse;

  final hadir = bulanIniData?['hadir']?.toString() ?? '0';
  final izin = bulanIniData?['izin']?.toString() ?? '0';
  final absen = bulanIniData?['absen']?.toString() ?? '0';

  return {
    'masuk': masuk,
    'keluar': keluar,
    'hadir': hadir,
    'izin': izin,
    'absen': absen,
  };
}

/// 🔹 Tampilkan modal (tanpa async)
void showRiwayatModal(
  BuildContext context, {
  required Map<String, dynamic>? masuk,
  required Map<String, dynamic>? keluar,
  required String hadir,
  required String izin,
  required String absen,
}) {
  if (_isRiwayatModalOpen) return; // Cegah buka modal baru
  _isRiwayatModalOpen = true;
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withValues(alpha: 0.3),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedValue = Curves.easeOutCubic.transform(animation.value) - 1.0;
      return Transform.translate(
        offset: Offset(0, curvedValue * -50),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _buildRiwayatModal(context, masuk, keluar, hadir, izin, absen),
        ),
      );
    },
  ).then((_) {
    _isRiwayatModalOpen = false;
  });
}

Widget _buildRiwayatModal(
  BuildContext context,
  Map<String, dynamic>? masuk,
  Map<String, dynamic>? keluar,
  String hadir,
  String izin,
  String absen,
) {
  return Material(
    color: Colors.transparent,
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Judul
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Riwayat Absen Hari Ini",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.blueGrey[900],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Card Riwayat
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icon/in.png',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Absen Masuk",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      masuk != null ? (masuk['shift'] ?? 'Masuk Kerja') : '-',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 4),
                  child: Text(
                    formatTanggalJamIndo(masuk?['jam']),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      'assets/icon/out.png',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Absen Keluar",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 4),
                  child: Text(
                    formatTanggalJamIndo(keluar?['jam']),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Presensi Bulan Ini
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Presensi Bulan Ini",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/laporan');
                },
                child: const Text(
                  "Lihat Laporan",
                  style: TextStyle(
                    color: Color(0xFF2485DA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPresensiCard("Hadir", "$hadir hari", Colors.greenAccent),
              _buildPresensiCard("Izin", "$izin hari", Colors.orange),
              _buildPresensiCard("Absen", "$absen hari", Colors.red),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

Widget _buildPresensiCard(String label, String value, Color color) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}
