import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'program_detail_screen.dart';
import '../../services/api_client.dart';

class ListProgramScreen extends StatefulWidget {
  const ListProgramScreen({super.key});

  @override
  State<ListProgramScreen> createState() => _ListProgramScreenState();
}

class _ListProgramScreenState extends State<ListProgramScreen> {
  bool loading = true;
  String? errorMsg;
  List programs = [];

  @override
  void initState() {
    super.initState();
    loadPrograms();
  }

  Future<void> loadPrograms() async {
    try {
      final response = await ApiClient.get("/programs");

      setState(() {
        programs = response["data"] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Program',
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
      backgroundColor: const Color(0xfff2f4f7),
      body: loading
          ? _shimmerList()
          : errorMsg != null
              ? Center(child: Text("Error: $errorMsg"))
              : programs.isEmpty
                  ? const Center(child: Text("Belum ada program"))
                  : _programList(),
    );
  }

  // =========================
  // SHIMMER LOADING
  // =========================
  Widget _shimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================
  // LIST PROGRAM
  // =========================
  Widget _programList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final p = programs[index];

        final title = p["title"] ?? "-";
        final image = p["image"] ?? "";
        final desc = p["description"] ?? "-";
        final start = p["start_date"] ?? "-";
        final end = p["end_date"] ?? "-";

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProgramDetailScreen(
                  title: title,
                  image: image,
                  description: desc,
                  startDate: start,
                  endDate: end,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE
                Image.network(
                  image.startsWith("http")
                      ? image
                      : "https://payroll.gomega.co.id/storage/$image",
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(height: 160, color: Colors.grey[300]),
                ),

                // TITLE
                Container(
                  width: double.infinity,
                  height: 65, // ⬅️ fixed height biar tinggi tetap
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.white,
                  alignment: Alignment
                      .centerLeft, // pastikan text rata kiri di tengah vertikal
                  child: Text(
                    title,
                    maxLines: 2, // ⬅️ maksimal 2 baris
                    overflow: TextOverflow
                        .ellipsis, // ⬅️ tambahkan titik-titik jika lebih
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF163A56),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
