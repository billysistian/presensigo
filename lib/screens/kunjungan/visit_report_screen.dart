import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_client.dart';
import '../../../utils/tanggal_indo.dart';
import '../../widgets/detail_kunjungan_modal.dart';

class VisitReportScreen extends StatefulWidget {
  const VisitReportScreen({super.key});

  @override
  State<VisitReportScreen> createState() => _VisitReportScreenState();
}

class _VisitReportScreenState extends State<VisitReportScreen> {
  bool loading = true;
  List<dynamic> data = [];

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<Map<String, dynamic>> bulanList = [
    {"label": "Januari", "value": 1},
    {"label": "Februari", "value": 2},
    {"label": "Maret", "value": 3},
    {"label": "April", "value": 4},
    {"label": "Mei", "value": 5},
    {"label": "Juni", "value": 6},
    {"label": "Juli", "value": 7},
    {"label": "Agustus", "value": 8},
    {"label": "September", "value": 9},
    {"label": "Oktober", "value": 10},
    {"label": "November", "value": 11},
    {"label": "Desember", "value": 12},
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    try {
      final res = await ApiClient.get(
          "/visit-report?month=$selectedMonth&year=$selectedYear");

      data = res["data"];
    } catch (e) {
      debugPrint("Error: $e");
    }
    setState(() => loading = false);
  }

  // ==============================
  //  MODAL PILIH BULAN - TAHUN
  // ==============================
  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SizedBox(
          height: 500,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text("Pilih Bulan & Tahun",
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF163A56),
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: bulanList.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text(
                        "${bulanList[i]["label"]} $selectedYear",
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      trailing: bulanList[i]["value"] == selectedMonth
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() => selectedMonth = bulanList[i]["value"]);
                        fetchData();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),

              // PILIH TAHUN
              Container(
                height: 65,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<int>(
                        value: selectedYear,
                        underline: const SizedBox(),
                        items: List.generate(5, (i) {
                          int y = DateTime.now().year - i;
                          return DropdownMenuItem(
                            value: y,
                            child: Text(
                              "$y",
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          );
                        }),
                        onChanged: (val) {
                          setState(() => selectedYear = val!);
                          fetchData();
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void showDetailModal(BuildContext context, String tanggal) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, //agar radius terlihat
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return DetailKunjunganModal(tanggal: tanggal);
      },
    );
  }

  // =========================
  // SHIMMER SKELETON LOADING
  // =========================
  Widget shimmerItem() {
    return Container(
      margin: const EdgeInsets.only(left: 18, right: 18, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(18),
      ),
      height: 90,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Laporan Kunjungan',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent, // wajib
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          // ================= FILTER BUTTON (ganti dropdown) ==================
          GestureDetector(
            onTap: _showMonthYearPicker,
            child: Container(
              margin: const EdgeInsets.only(left: 18),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${bulanList[selectedMonth - 1]["label"]} $selectedYear",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ============ LIST LAPORAN ================
          Expanded(
            child: loading
                ? ListView.builder(
                    itemCount: 6,
                    itemBuilder: (_, __) => shimmerItem(),
                  )
                : ListView.builder(
                    itemCount: data.length,
                    padding: const EdgeInsets.only(bottom: 30),
                    itemBuilder: (context, i) {
                      final item = data[i];
                      bool done = item["status"] == "Lengkap";

                      return InkWell(
                        onTap: () {
                          final tanggalApi = convertToApiDate(item["tanggal"]);
                          showDetailModal(context, tanggalApi);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          margin: const EdgeInsets.only(
                              left: 18, right: 18, bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE7E7E7)),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // LEFT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["tanggal"],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF0D1B34),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "${item["jumlah_kunjungan"]} Kunjungan",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFF9AA0A6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // DIVIDER
                              Container(
                                height: 40,
                                width: 1.3,
                                color: Colors.grey.shade300,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 14),
                              ),

                              // RIGHT
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        done
                                            ? Icons.check_circle_outline
                                            : Icons.warning_amber_rounded,
                                        color: done
                                            ? Colors.green
                                            : Colors.orangeAccent,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        item["status"],
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: done
                                              ? Colors.green
                                              : Colors.orangeAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${item["jam"]}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
