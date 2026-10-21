import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../../utils/toast.dart';
import 'package:image_picker/image_picker.dart';

class LeaveFormScreen extends StatefulWidget {
  const LeaveFormScreen({super.key});

  @override
  State<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  String? selectedLeaveType = "Izin";
  DateTimeRange? selectedRange;

  final TextEditingController descriptionController = TextEditingController();

  File? attachmentFile;
  final ImagePicker _picker = ImagePicker();

  String get rangeText {
    if (selectedRange == null) return "Pilih tanggal";
    final start = DateFormat('yyyy-MM-dd').format(selectedRange!.start);
    final end = DateFormat('yyyy-MM-dd').format(selectedRange!.end);
    if (start == end) {
      return start;
    }
    return "$start - $end";
  }

  bool get isFormValid {
    return selectedLeaveType != null &&
        selectedRange != null &&
        descriptionController.text.isNotEmpty;
  }

  // ===========================
  // PICK ATTACHMENT
  // ===========================
  Future<void> pickAttachment() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        attachmentFile = File(image.path);
      });
    }
  }

  // ===========================
  // CUSTOM DATE RANGE PICKER
  // ===========================
  void showCustomDateRangePicker() async {
    DateTime? startDate = selectedRange?.start;
    DateTime? endDate = selectedRange?.end;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4)),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "Pilih Rentang Tanggal",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF163A56)),
                    ),

                    const SizedBox(height: 20),

                    CalendarDatePicker(
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                      currentDate: DateTime.now(),
                      onDateChanged: (date) {
                        setModalState(() {
                          if (startDate == null) {
                            /// Klik pertama = start
                            startDate = date;
                            endDate = null;
                          } else if (endDate == null) {
                            /// Klik kedua = end
                            if (date.isBefore(startDate!)) {
                              endDate = startDate;
                              startDate = date;
                            } else {
                              endDate = date;
                            }
                          } else {
                            /// Jika user klik ke-3 → reset & mulai dari awal
                            startDate = date;
                            endDate = null;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    /// Teks preview
                    Text(
                      startDate == null
                          ? "Belum memilih tanggal"
                          : endDate == null
                              ? "Mulai: ${DateFormat('dd MMM yyyy').format(startDate!)}"
                              : "Range: ${DateFormat('dd MMM yyyy').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}",
                      style: const TextStyle(fontSize: 14),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (startDate == null) {
                          Navigator.pop(context);
                          return;
                        }

                        setState(() {
                          selectedRange = DateTimeRange(
                            start: startDate!,
                            end: endDate ??
                                startDate!, // jika hanya pilih 1 tanggal
                          );
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(260, 50),
                        backgroundColor: const Color(0xFF163A56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Selesai",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================
  // BOTTOM SHEET KATEGORI IZIN
  // ===========================
  void showLeaveTypeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final items = ["Izin", "Cuti", "Sakit"];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Kategori Izin",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF163A56),
                ),
              ),
              const SizedBox(height: 10),
              ...items.map(
                (item) {
                  final isSelected = selectedLeaveType == item;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE7F1FD)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() => selectedLeaveType = item);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected
                                        ? const Color(0xFF1D6FE8)
                                        : const Color(0xFF163A56),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check,
                                    color: Color(0xFF1D6FE8), size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ===========================
  // SUBMIT LEAVE
  // ===========================
  Future<void> submitLeave() async {
    try {
      debugPrint("=== SUBMIT LEAVE START ===");

      final start = selectedRange!.start;
      final end = selectedRange!.end;

      final startDate = DateFormat("yyyy-MM-dd").format(start);

      // Jika end == start → user hanya pilih 1 tanggal
      final endDate = start == end
          ? "" // KOSONGKAN
          : DateFormat("yyyy-MM-dd").format(end);

      final fields = {
        "leave_type": selectedLeaveType!,
        "start_date": startDate,
        "end_date": endDate,
        "description": descriptionController.text,
      };

      debugPrint("Fields: $fields");

      final files = attachmentFile != null
          ? [
              {
                "field": "attachment",
                "file": attachmentFile!,
              }
            ]
          : null;

      final streamed = await ApiClient.postMultipart(
        "/leave",
        fields: fields,
        files: files,
      );

      final responseBody = await streamed.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (!mounted) return;

      if (streamed.statusCode == 201) {
        showModernToast(context, data['message'], success: true);
        Navigator.pop(context, true);
      } else {
        showModernToast(context, data['message'] ?? "Gagal", success: false);
      }
    } catch (e, stack) {
      debugPrint("=== ERROR SUBMIT LEAVE ===");
      debugPrint("Error: $e");
      debugPrint("Stack trace: $stack");
      showModernToast(context, "Terjadi kesalahan: $e", success: false);
    }
  }

  // ===========================
  // UI
  // ===========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Pengajuan Izin Hari",
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF163A56),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF163A56)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====================
            // KATEGORI IZIN
            // ====================
            const Text(
              "Kategori Izin",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1E3A5F)),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: showLeaveTypeModal,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedLeaveType ?? "Pilih Kategori",
                      style: TextStyle(
                        color: selectedLeaveType == null
                            ? Colors.grey.shade400
                            : const Color(0xFF163A56),
                        fontSize: 15,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ====================
            // DURASI IZIN
            // ====================
            const Text(
              "Durasi Izin",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1E3A5F)),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rangeText,
                  style: TextStyle(
                      fontSize: 15,
                      color: selectedRange == null
                          ? Colors.grey.shade400
                          : const Color(0xFF163A56)),
                ),
                IconButton(
                  onPressed: showCustomDateRangePicker,
                  icon: Image.asset(
                    "assets/icon/calendar.png",
                    width: 24,
                  ),
                )
              ],
            ),

            const Divider(),
            const SizedBox(height: 20),

            // ====================
            // KETERANGAN
            // ====================
            const Text(
              "Keterangan",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: descriptionController,
              maxLength: 2000,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Keterangan Izin",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                counter: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Maksimal 50 karakter",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    Text(
                      "${descriptionController.text.length}/2000",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
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
            ),

            const SizedBox(height: 20),

            // ====================
            // LAMPIRAN
            // ====================
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Lampiran",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1E3A5F)),
                ),
                Text(
                  "Opsional",
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: pickAttachment,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        attachmentFile == null
                            ? "Belum ada lampiran"
                            : attachmentFile!.path.split('/').last,
                        style: TextStyle(
                          color: attachmentFile == null
                              ? Colors.grey.shade400
                              : const Color(0xFF163A56),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Unggah Berkas",
                      style: TextStyle(
                        color: Color(0xFF2485DA),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ===========================
      // BUTTON KIRIM PENGAJUAN
      // ===========================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: isFormValid ? submitLeave : null,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            backgroundColor:
                isFormValid ? const Color(0xFF2485DA) : Colors.grey.shade100,
            foregroundColor: isFormValid ? Colors.white : Colors.grey.shade400,
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
