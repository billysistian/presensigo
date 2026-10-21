import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../../utils/tanggal_indo.dart';
import 'package:shimmer/shimmer.dart';

class SalarySlipScreen extends StatefulWidget {
  const SalarySlipScreen({super.key});

  @override
  State<SalarySlipScreen> createState() => _SalarySlipScreenState();
}

class _SalarySlipScreenState extends State<SalarySlipScreen> {
  Map<String, dynamic>? data; // full "data" dari API
  bool loading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchSlip();
  }

  Future<void> fetchSlip() async {
    try {
      final response = await ApiClient.get("/payroll/my-slip");

      setState(() {
        data = response["data"]; // ambil hanya bagian "data"
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        loading = false;
      });
    }
  }

  // ===================== FORMAT UANG =====================
  String rupiah(dynamic number) {
    try {
      double n = double.parse(number.toString());
      return "Rp ${n.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
    } catch (_) {
      return "Rp 0";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f4f7),
      appBar: AppBar(
        title: const Text(
          'Slip Gaji',
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
      body: loading
          ? _shimmerLoading()
          : errorMsg != null
              ? Center(child: Text("Gagal memuat data: $errorMsg"))
              : data == null
                  ? const Center(child: Text("Slip gaji belum tersedia"))
                  : _content(),
    );
  }

  Widget _shimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          _shimmerBox(height: 140, width: double.infinity, radius: 20),
          const SizedBox(height: 20),

          // Info section
          _shimmerBox(height: 100, width: double.infinity, radius: 16),
          const SizedBox(height: 20),

          // Earnings
          _shimmerBox(height: 140, width: double.infinity, radius: 16),
          const SizedBox(height: 20),

          // Deductions
          _shimmerBox(height: 120, width: double.infinity, radius: 16),
          const SizedBox(height: 20),

          // Net salary
          _shimmerBox(height: 80, width: double.infinity, radius: 20),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    required double width,
    double radius = 12,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  // ======================= CONTENT =========================
  Widget _content() {
    final payroll = data!["payroll"];
    final employee = payroll["employee"];

    final allowances = List<Map<String, dynamic>>.from(data!["allowances"]);
    final deductions = List<Map<String, dynamic>>.from(data!["deductions"]);
    final bonuses = List<Map<String, dynamic>>.from(data!["bonuses"] ?? []);

    double totalAllowance =
        allowances.fold(0, (sum, item) => sum + double.parse(item["amount"]));

    double totalDeduction =
        deductions.fold(0, (sum, item) => sum + double.parse(item["amount"]));

    double totalBonus =
        bonuses.fold(0, (sum, item) => sum + double.parse(item["amount"]));

    double basic = double.parse(payroll["basic_salary"]);
    double takeHome = basic + totalAllowance + totalBonus - totalDeduction;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _headerCard(),
          const SizedBox(height: 20),
          _infoSection(payroll, employee),
          const SizedBox(height: 20),

          // Tetap tanpa ubah parameter
          _earningSection(
              basic, allowances, totalAllowance, bonuses, totalBonus),

          const SizedBox(height: 20),
          _deductionSection(deductions, totalDeduction),
          const SizedBox(height: 20),
          _netSalaryCard(takeHome),
        ],
      ),
    );
  }

  // ======================= HEADER =========================
  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF057CE4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Slip Gaji",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            "PT. Gomega Asia Cemerlang",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ======================= INFO =========================
  Widget _infoSection(payroll, employee) {
    return _card(
      child: Column(
        children: [
          _infoRow("Nama", employee["nama"]),
          _infoRow("Jabatan", employee["position"]?["position_name"] ?? "-"),
          _infoRow("Periode", formatBulanTahun(payroll["pay_date"])),
          // _infoRow("Hari Kerja", "${payroll["working_days"]} hari"),
          // _infoRow("Minggu Kerja", "${payroll["weekly"]} minggu"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF163A56))),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ======================= EARNINGS =========================
  Widget _earningSection(
    double basic,
    List allowances,
    double totalAllow,
    List bonuses,
    double totalBonus,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Pendapatan"),

          _moneyRow("Gaji Pokok", rupiah(basic)),

          // Tunjangan
          for (var a in allowances) _moneyRow(a["nama"], rupiah(a["amount"])),

          // Bonus
          for (var b in bonuses)
            _moneyRow(b["bonus_name"], rupiah(b["amount"])),

          const Divider(),

          _moneyRow(
            "Total Pendapatan",
            rupiah(basic + totalAllow + totalBonus),
            bold: true,
          ),
        ],
      ),
    );
  }

  // ======================= DEDUCTIONS =========================
  Widget _deductionSection(List deductions, double total) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Potongan"),
          if (deductions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("- Tidak ada potongan -"),
            ),
          for (var d in deductions) _moneyRow(d["nama"], rupiah(d["amount"])),
          if (deductions.isNotEmpty) const Divider(),
          if (deductions.isNotEmpty)
            _moneyRow("Total Potongan", rupiah(total), bold: true),
        ],
      ),
    );
  }

  // ======================= NET SALARY =========================
  Widget _netSalaryCard(double amount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF057CE4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Diterima",
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text(
            rupiah(amount),
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ======================= HELPERS =========================
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _title(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        t,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _moneyRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF163A56), fontSize: 14)),
          Text(
            value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600),
          )
        ],
      ),
    );
  }
}
