import 'package:intl/intl.dart';

String formatBulanPanjang(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return "-";

  try {
    final date = DateTime.parse(dateStr);
    return DateFormat("EEEE, dd MMMM yyyy", "id_ID").format(date);
  } catch (e) {
    return "-";
  }
}

String formatBulanTahun(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return "-";

  try {
    final date = DateTime.parse(dateStr);
    return DateFormat("MMMM yyyy", "id_ID").format(date);
  } catch (e) {
    return "-";
  }
}

String formatBulanPendek(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return "-";

  try {
    // Contoh hasil: 8 Nov 2025
    final date = DateTime.parse(dateStr);
    return DateFormat("d MMM yyyy", "id_ID").format(date);
  } catch (e) {
    return "-";
  }
}

String formatBulan(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return "-";

  try {
    // Contoh hasil: 8 November 2025
    final date = DateTime.parse(dateStr);
    return DateFormat("d MMMM yyyy", "id_ID").format(date);
  } catch (e) {
    return "-";
  }
}

String formatTanggalJamIndo(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return "-";

  try {
    // Contoh hasil: 5 Juli 2025 08:00 WIB
    final date = DateTime.parse(dateStr);
    final formatted = DateFormat("dd MMM yyyy HH:mm", "id_ID").format(date);
    return "$formatted WIB";
  } catch (e) {
    return "-";
  }
}

String convertToApiDate(String tanggal) {
  final months = {
    "Januari": "01",
    "Februari": "02",
    "Maret": "03",
    "April": "04",
    "Mei": "05",
    "Juni": "06",
    "Juli": "07",
    "Agustus": "08",
    "September": "09",
    "Oktober": "10",
    "November": "11",
    "Desember": "12",
  };

  final parts = tanggal.split(" "); // contoh: ["5", "November", "2025"]
  final day = parts[0].padLeft(2, '0'); // contoh: "05"
  final month = months[parts[1]]!;
  final year = parts[2];

  return "$year-$month-$day"; // contoh: 2025-11-05
}
