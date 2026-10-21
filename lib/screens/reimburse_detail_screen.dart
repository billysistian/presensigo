import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../../utils/toast.dart';

class ReimburseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReimburseDetailScreen({super.key, required this.data});

  String formatTanggal(String date) {
    final d = DateTime.parse(date);
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(d);
  }

  String formatTanggalShort(String date) {
    final d = DateTime.parse(date);
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final status = (data["status"] ?? "menunggu").toLowerCase();
    Color statusTextColor;
    if (status == "disetujui") {
      statusTextColor = Colors.green;
    } else if (status == "ditolak") {
      statusTextColor = Colors.red;
    } else {
      statusTextColor = Colors.orange;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Detail Reimburse",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF163A56),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF163A56)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0), // warna border
            height: 1, // ketebalan border
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Text(
                "Keterangan Reimburse",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF163A56),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _detailItem(
              title: "Tanggal",
              value: formatTanggal(data["reimburse_date"]),
            ),

            const SizedBox(height: 18),

            _detailItem(
              title: "Nominal Reimburse",
              value:
                  "Rp ${data['nominal'].toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}",
            ),

            const SizedBox(height: 18),

            _detailItem(
              title: "Deskripsi",
              value: data["description"] ?? "-",
            ),

            const SizedBox(height: 30),
            Container(height: 8, color: const Color(0xFFF4F6F9)),
            const SizedBox(height: 24),

            // ==========================
            // STATUS PENGAJUAN
            // ==========================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Status Pengajuan",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF163A56),
                    ),
                  ),
                  Text(
                    data["status"] ?? "-",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STEP 1 — Status utama
                  _timelineRow(
                    icon: _statusIcon(
                      status == "disetujui"
                          ? Colors.green
                          : status == "ditolak"
                              ? Colors.red
                              : Colors.orange,
                      status == "disetujui"
                          ? Icons.check
                          : status == "ditolak"
                              ? Icons.close
                              : Icons.access_time,
                    ),
                    showLine: true,
                    lineHeight: 34,
                    child: Text(
                      status == "disetujui"
                          ? "Selesai"
                          : status == "ditolak"
                              ? "Ditolak"
                              : "Menunggu",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF163A56),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (status != "menunggu") ...[
                    _timelineRow(
                      icon: _circleSmall(),
                      showLine: true,
                      lineHeight: 34,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == "ditolak"
                                ? "Tidak disetujui oleh Admin"
                                : "Disetujui oleh Admin",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF163A56),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatTanggalShort(data["updated_at"]),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // STEP 3 — Pengajuan terkirim
                  _timelineRow(
                    icon: _circleSmall(),
                    showLine: false,
                    lineHeight: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pengajuan reimburse telah terkirim",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF163A56),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatTanggalShort(data["created_at"]),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: (data["status"] == "Menunggu")
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Batalkan Pengajuan?"),
                          content: const Text(
                              "Pengajuan reimburse yang sudah dikirim akan dibatalkan."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Tidak"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Ya, Batalkan"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final response =
                            await ApiClient.delete("/reimburse/${data["id"]}");
                        // ignore: use_build_context_synchronously
                        showModernToast(context, response['message'],
                            success: true);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, true);
                      }
                    },
                    child: Text(
                      "Batalkan Pengajuan",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // ============================
  // WIDGET REUSABLE / CLEAN CODE
  // ============================

  Widget _detailItem({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF163A56),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineRow({
    required Widget icon,
    required bool showLine,
    required double lineHeight,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            icon,
            if (showLine)
              Container(
                width: 2,
                height: lineHeight,
                color: const Color(0xFFE5E7EB),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }

  Widget _statusIcon(Color color, IconData icon) {
    return Container(
      width: 20, // ukuran FIX seperti screenshot
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 14),
    );
  }

  Widget _circleSmall() {
    return Container(
      width: 20, // ukuran FIX seperti screenshot
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 12, color: Color(0xFF9CA3AF)),
    );
  }
}
