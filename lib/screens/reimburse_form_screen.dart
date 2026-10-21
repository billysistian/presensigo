import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../../utils/toast.dart';

class ReimburseFormScreen extends StatefulWidget {
  const ReimburseFormScreen({super.key});

  @override
  State<ReimburseFormScreen> createState() => _ReimburseFormScreenState();
}

class _ReimburseFormScreenState extends State<ReimburseFormScreen> {
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController nominalController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  DateTime? selectedDate;

  bool get isFormValid {
    return tanggalController.text.isNotEmpty &&
        nominalController.text.isNotEmpty &&
        deskripsiController.text.isNotEmpty;
  }

  Future<void> submitOvertime() async {
    try {
      final body = {
        "reimburse_date": tanggalController.text,
        "nominal": int.parse(nominalController.text),
        "description": deskripsiController.text,
      };

      final response = await ApiClient.post('/reimburse', body);

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
          'Pengajuan Reimburse',
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
            // Tanggal Reimburse
            TextField(
              controller: tanggalController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Tanggal Reimburse",
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
              "Nominal Reimburse",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: nominalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "0",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Text(
                    "Rp",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(189, 189, 189, 1),
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                hintText: "Deskripsi Klaim Reimburse",
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
            foregroundColor: isFormValid ? Colors.white : Colors.grey.shade100,
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
