import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LemburItem extends StatelessWidget {
  final String title;
  final int jam;
  final int menit;
  final DateTime tanggal;
  final String status;

  const LemburItem({
    super.key,
    required this.title,
    required this.jam,
    required this.menit,
    required this.tanggal,
    required this.status,
  });

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange; // Menunggu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ICON DI KIRI
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.document_scanner,
                size: 20,
                color: Color(0xFF163A56),
              ),
            ),

            const SizedBox(width: 12),

            // TEXT BAGIAN KIRI
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF163A56),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$jam Jam $menit Menit",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF163A56),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tanggal),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // STATUS DI KANAN
            Text(
              status,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: getStatusColor(status),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(
          color: Colors.grey.shade300,
          thickness: 1,
        ),
      ],
    );
  }
}
