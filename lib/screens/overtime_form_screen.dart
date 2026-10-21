import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../../utils/toast.dart';

class OvertimeFormScreen extends StatefulWidget {
  const OvertimeFormScreen({super.key});

  @override
  State<OvertimeFormScreen> createState() => _OvertimeFormScreenState();
}

class _OvertimeFormScreenState extends State<OvertimeFormScreen> {
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jamController = TextEditingController();
  final TextEditingController menitController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  DateTime? selectedDate;

  bool get isFormValid {
    return tanggalController.text.isNotEmpty &&
        jamController.text.isNotEmpty &&
        menitController.text.isNotEmpty &&
        deskripsiController.text.isNotEmpty;
  }

  Future<void> submitOvertime() async {
    try {
      final body = {
        "tanggal_lembur": tanggalController.text,
        "jam": int.parse(jamController.text),
        "menit": int.parse(menitController.text),
        "deskripsi": deskripsiController.text,
      };

      final response = await ApiClient.post('/overtime', body);

      if (!mounted) return;

      showModernToast(context, response['message'], success: true);

      Navigator.pop(context, true);
    } catch (e) {
      showModernToast(context, 'Terjadi kesalahan: $e', success: false);
    }
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pengajuan Lembur',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF163A56),
            fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanggal Lembur
            TextField(
              controller: tanggalController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Tanggal Lembur",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                suffixIcon: IconButton(
                  onPressed: pickDate,
                  icon: Image.asset(
                    "assets/icon/calendar.png",
                    width: 24,
                    height: 24,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2485DA)),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            const Text(
              "Durasi Lembur",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E3A5F),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jamController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Jam",
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2485DA)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: menitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Menit",
                      labelStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF2485DA)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Deskripsi",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: deskripsiController,
              maxLines: 2,
              maxLength: 2000,
              decoration: InputDecoration(
                hintText: "Deskripsi Lembur",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2485DA)),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: isFormValid ? submitOvertime : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            backgroundColor:
                isFormValid ? const Color(0xFF2485DA) : Colors.grey.shade50,
            foregroundColor: isFormValid ? Colors.white : Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Text(
            "Kirim Pengajuan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
