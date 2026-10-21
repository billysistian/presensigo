import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import 'leave_form_screen.dart';
import 'leave_detail_screen.dart';

class LeaveListScreen extends StatefulWidget {
  const LeaveListScreen({super.key});

  @override
  State<LeaveListScreen> createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
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
        "/leave?month=$selectedMonth&year=$selectedYear",
      );
      data = res["data"];
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() => loading = false);
  }

  // ========================
  // MODAL PILIH BULAN TAHUN
  // ========================
  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
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
              Text(
                "Pilih Bulan & Tahun",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: const Color(0xFF163A56),
                    fontWeight: FontWeight.w600),
              ),
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

  Widget shimmerItem() {
    return Container(
      margin: const EdgeInsets.only(left: 18, right: 18, bottom: 12),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  // Format tanggal Indonesia
  String formatTanggal(String date) {
    final d = DateTime.parse(date);
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(d);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "disetujui":
        return Colors.green;
      case "ditolak":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Izin',
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
      body: Column(
        children: [
          // Card Filter Section
          Container(
            margin: const EdgeInsets.all(18),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Tugas Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Riwayat Izin",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Month Year Picker
                GestureDetector(
                  onTap: _showMonthYearPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${getMonthName(selectedMonth)} $selectedYear",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================
          // LIST LEMBUR
          // ============================
          Expanded(
            child: loading
                ? ListView.builder(
                    itemCount: 10,
                    itemBuilder: (_, __) => shimmerItem(),
                  )
                : data.isEmpty
                    ? Center(
                        child: Text(
                          "Tidak ada data cuti",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: data.length,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemBuilder: (context, i) {
                          final item = data[i];

                          return InkWell(
                            onTap: () async {
                              final refreshed = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LeaveDetailScreen(data: item),
                                ),
                              );

                              if (refreshed == true) {
                                fetchData();
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ICON KIRI
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_outlined,
                                      size: 20,
                                      color: Color(0xFF2485DA),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // TEXT UTAMA
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["description"] ?? "-",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item["end_date"] != null &&
                                                  item["end_date"] != ""
                                              ? "${formatTanggal(item["start_date"])} - ${formatTanggal(item["end_date"])}"
                                              : formatTanggal(
                                                  item["start_date"]),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // STATUS
                                  Text(
                                    item["status"],
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: getStatusColor(item["status"]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Bottom button Ajukan Cuti/Izin
          Container(
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
                    backgroundColor: const Color(0xFF2485DA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaveFormScreen(),
                      ),
                    );

                    if (result == true) {
                      fetchData();
                    }
                  },
                  child: Text(
                    "Ajukan Izin",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
