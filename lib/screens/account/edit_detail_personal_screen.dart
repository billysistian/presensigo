import 'dart:io';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../utils/toast.dart';

class EditDetailScreen extends StatefulWidget {
  final Map<String, dynamic> userData; // ✅ kirim dari halaman sebelumnya

  const EditDetailScreen({super.key, required this.userData});

  @override
  State<EditDetailScreen> createState() => _EditDetailScreenState();
}

class _EditDetailScreenState extends State<EditDetailScreen> {
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? _selectedAvatar;
  bool _loading = false;
  String? _birthDateApiFormat;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final userData = widget.userData;

    final rawDate = userData["tanggal_lahir"];
    final address = userData["alamat"] ?? "";

    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        final parsed = DateTime.parse(rawDate);
        birthDateController.text =
            DateFormat("d MMMM yyyy", "id_ID").format(parsed);
        _birthDateApiFormat = DateFormat("yyyy-MM-dd").format(parsed);
      } catch (_) {
        birthDateController.text = rawDate;
      }
    }

    addressController.text = address;

    final rawUrl = userData["avatar_url"];
    if (rawUrl != null && rawUrl.isNotEmpty) {
      if (rawUrl.startsWith('http')) {
        _avatarUrl = rawUrl;
      } else {
        _avatarUrl = "$storageUrl/storage/$rawUrl";
      }
    } else {
      _avatarUrl = null;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        birthDateController.text =
            DateFormat("d MMMM yyyy", "id_ID").format(picked);
        _birthDateApiFormat = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedAvatar = File(picked.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _loading = true);

    try {
      final response = await ApiClient.postMultipart(
        '/user/update',
        fields: {
          'birthday': _birthDateApiFormat ?? '',
          'address': addressController.text,
        },
        files: _selectedAvatar != null
            ? [
                {'field': 'foto', 'file': _selectedAvatar!},
              ]
            : [],
      );

      final responseBody = await response.stream.bytesToString();
      final json = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedUser = json['user'];
        final prefs = await AuthService.getUserData();

        final newAvatarUrl = updatedUser['avatar'] ??
            updatedUser['avatar_url'] ??
            prefs["avatar_url"];

        // ✅ Simpan data terbaru ke AuthService
        await AuthService.saveToken(
          token: prefs["token"] ?? "",
          userName: prefs["user_name"] ?? "",
          avatarUrl: newAvatarUrl,
          email: prefs["email"] ?? "",
          tanggalLahir: _birthDateApiFormat ?? prefs["tanggal_lahir"],
          alamat: addressController.text,
          role: prefs["role"],
        );

        // ✅ Update UI tanpa reload API
        setState(() {
          _avatarUrl = newAvatarUrl;
          _selectedAvatar = null;
        });

        if (mounted) {
          showModernToast(context, 'Perubahan berhasil disimpan!',
              success: true);

          // ✅ Kirim balik data baru ke halaman sebelumnya biar auto update
          Navigator.pop(context, {
            'tanggal_lahir': _birthDateApiFormat,
            'alamat': addressController.text,
            'avatar_url': newAvatarUrl,
          });
        }
      } else {
        if (!mounted) return;
        showModernToast(context, ('Gagal menyimpan: $responseBody'),
            success: false);
      }
    } catch (e) {
      if (!mounted) return;
      showModernToast(context, ('Terjadi kesalahan: $e'), success: false);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF163A56);
    const Color labelColor = Color(0xFF163A56);
    const Color backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Personal',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF163A56),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF163A56)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Avatar
            Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedAvatar != null
                      ? FileImage(_selectedAvatar!)
                      : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                          ? NetworkImage(_avatarUrl!)
                          : null) as ImageProvider<Object>?,
                  child: (_selectedAvatar == null &&
                          (_avatarUrl == null || _avatarUrl!.isEmpty))
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _loading ? null : _pickImage,
                  child: const Text(
                    "Ganti Foto",
                    style: TextStyle(
                      color: Color(0xFF2485DA),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Tanggal lahir
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tanggal Lahir",
                style: TextStyle(
                  color: labelColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 55,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: _pickDate,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      birthDateController.text.isNotEmpty
                          ? birthDateController.text
                          : "Pilih tanggal lahir",
                      style: const TextStyle(fontSize: 15, color: textColor),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Alamat
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Alamat",
                style: TextStyle(
                  color: labelColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: addressController,
                style: const TextStyle(fontSize: 15, color: textColor),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Masukkan Alamat",
                  hintStyle: TextStyle(color: Colors.grey),
                  isCollapsed: true,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Info box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info,
                    color: textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Keterangan",
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "Karyawan hanya bisa mengubah foto profil, tanggal lahir, dan alamat. "
                          "Untuk perubahan data lain silahkan menghubungi administrator.",
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2485DA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Simpan Perubahan",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
