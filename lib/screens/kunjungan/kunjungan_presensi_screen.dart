import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/api_client.dart';
import 'presensi_page.dart';
import 'tambah_titik_kunjungan_screen.dart';
import 'visit_report_screen.dart';
import '../../utils/toast.dart';
import '../../utils/tanggal_indo.dart';

class KunjunganPresensiScreen extends StatefulWidget {
  const KunjunganPresensiScreen({super.key});

  @override
  State<KunjunganPresensiScreen> createState() =>
      _KunjunganPresensiScreenState();
}

class _KunjunganPresensiScreenState extends State<KunjunganPresensiScreen> {
  bool isLoading = true;
  bool isLoadingMore = false;
  int totalAbsen = 0;
  int totalToko = 0;
  List<dynamic> kunjungan = [];
  String search = "";
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchKunjungan();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchKunjungan() async {
    try {
      final response = await ApiClient.get("/kunjungan");

      if (response["outlet"] != null) {
        setState(() {
          totalAbsen = response["total_absen"] ?? 0;
          totalToko = response["total_toko"] ?? 0;
          kunjungan = response["outlet"];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil kunjungan: $e");
      setState(() => isLoading = false);
      if (!mounted) return;
      showModernToast(context, 'Gagal memuat data kunjungan', success: false);
    }
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    await fetchKunjungan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          // HEADER BIRU DENGAN SHAPE
          Container(
            width: double.infinity,
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
            child: Stack(
              children: [
                // Bentuk shape di kanan atas
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

                // CONTENT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // APP BAR (padding minimal di kiri)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 40, left: 4, right: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Kunjungan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          // 👇 dorong elemen ke kanan
                          const Spacer(),

                          IconButton(
                            icon: Image.asset(
                              'assets/icon/paper-white.png',
                              width: 30,
                              height: 30,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const VisitReportScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CARD & SEARCH (dengan padding horizontal)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // CARD INFO ATAS
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Yang Harus Dikunjungi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF163A56),
                                        ),
                                      ),
                                      Text(
                                        formatBulanPanjang(
                                            DateTime.now().toIso8601String()),
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            FractionallySizedBox(
                                              widthFactor: totalToko > 0
                                                  ? (totalAbsen / totalToko)
                                                      .clamp(0.0, 1.0)
                                                  : 0,
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 400),
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF057CE4),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$totalAbsen/$totalToko',
                                        style: const TextStyle(
                                          color: Color(0xFF163A56),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // SEARCH BAR DENGAN TOMBOL CARI
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (val) =>
                                      setState(() => search = val),
                                  decoration: const InputDecoration(
                                    hintText: 'Masukkan Nama Outlet',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.asset(
                                    'assets/icon/search-outline.png', // ganti dengan path PNG kamu
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),

          // LIST OUTLET
          Expanded(
            child: isLoading
                ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                        top: 0, left: 1, right: 1, bottom: 8),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 120,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: const Color(0xFF057CE4),
                    backgroundColor: Colors.white,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                          top: 0, left: 1, right: 1, bottom: 8),
                      itemCount:
                          kunjungan.length + 1, // +1 untuk section tambah
                      itemBuilder: (context, index) {
                        // SECTION TAMBAH KUNJUNGAN BARU
                        if (index == 0) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Anda bisa menambahkan titik kunjungan baru',
                                    style: TextStyle(
                                      color: Color(0xFF163A56),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TambahTitikKunjunganScreen(),
                                      ),
                                    );

                                    // Refresh data jika berhasil tambah
                                    if (result == true) {
                                      fetchKunjungan();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Color(0xFF163A56),
                                  ),
                                  label: const Text(
                                    'Tambah',
                                    style: TextStyle(
                                      color: Color(0xFF163A56),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // LIST OUTLET (index - 1 karena ada section tambah di atas)
                        final outlet = kunjungan[index - 1];
                        final namaOutlet = outlet['pelanggan'] ?? 'Tanpa Nama';

                        if (search.isNotEmpty &&
                            !namaOutlet
                                .toLowerCase()
                                .contains(search.toLowerCase())) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 1),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                namaOutlet,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF163A56),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: outlet['sudahAbsen']
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PresensiPage(outlet: outlet),
                                          ),
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: outlet['sudahAbsen']
                                      ? Colors.green[600]
                                      : const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 2,
                                ),
                                child: outlet['sudahAbsen']
                                    ? const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.white, size: 20),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Presensi'),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
