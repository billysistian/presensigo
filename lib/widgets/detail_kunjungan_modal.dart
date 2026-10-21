import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_client.dart';
import '../../utils/tanggal_indo.dart';

class DetailKunjunganModal extends StatefulWidget {
  final String tanggal;

  const DetailKunjunganModal({
    super.key,
    required this.tanggal,
  });

  @override
  State<DetailKunjunganModal> createState() => _DetailKunjunganModalState();
}

class _DetailKunjunganModalState extends State<DetailKunjunganModal> {
  bool loading = true;
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      final res = await ApiClient.get(
        "/detail-kunjungan?tanggal=${widget.tanggal}",
      );
      data = res["data"] ?? [];
    } catch (e) {
      debugPrint("ERROR FETCH DETAIL: $e");
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HANDLE BAR
            Center(
              child: Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // TITLE
            const Text(
              "Detail Kunjungan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            // SUBTITLE
            Text(
              formatBulan(widget.tanggal),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 18),

            // LIST
            Expanded(
              child: loading
                  ? _shimmerList()
                  : data.isEmpty
                      ? Center(
                          child: Text(
                            "Belum ada kunjungan",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : ListView.separated(
                          itemCount: data.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = data[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F8FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item["nama_outlet"],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item["jam"],
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // SHIMMER LIST
  Widget _shimmerList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
