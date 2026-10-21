import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../services/auth_service.dart';
import 'edit_detail_personal_screen.dart';

class DetailPersonalScreen extends StatefulWidget {
  final String userName;
  final String? role;
  final String? avatarUrl;
  final String? email;
  final String? tanggalLahir;
  final String? alamat;

  const DetailPersonalScreen({
    super.key,
    required this.userName,
    this.role,
    this.avatarUrl,
    this.email,
    this.tanggalLahir,
    this.alamat,
  });

  @override
  State<DetailPersonalScreen> createState() => _DetailPersonalScreenState();
}

class _DetailPersonalScreenState extends State<DetailPersonalScreen> {
  late String? _avatarUrl;
  late String? _tanggalLahir;
  late String? _alamat;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null);
    _avatarUrl = widget.avatarUrl;
    _tanggalLahir = widget.tanggalLahir;
    _alamat = widget.alamat;
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF163A56);
    const Color labelColor = Color(0xFF9AA7B6);
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
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                          ? NetworkImage(
                              _avatarUrl!.startsWith('http')
                                  ? _avatarUrl!
                                  : 'https://payroll.gomega.co.id/storage/${_avatarUrl!}',
                            )
                          : null,
                  child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                      ? const Icon(Icons.person,
                          color: Color(0xFF1677FF), size: 48)
                      : null,
                ),
              ),
              const SizedBox(height: 32),

              // Info user
              buildInfoItem(
                  'Nama Lengkap', widget.userName, textColor, labelColor),
              const SizedBox(height: 16),
              buildInfoItem(
                  'Email', widget.email ?? '-', textColor, labelColor),
              const SizedBox(height: 16),
              buildInfoItem('Tanggal Lahir', formatTanggalIndo(_tanggalLahir),
                  textColor, labelColor),
              const SizedBox(height: 16),
              buildInfoItem('Alamat', _alamat ?? '-', textColor, labelColor),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            side: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          onPressed: () async {
            final userData = await AuthService.getUserData();

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditDetailScreen(userData: userData),
                ),
              );

              if (!mounted) return;
              if (result != null) {
                setState(() {
                  _tanggalLahir = result['tanggal_lahir'] ?? _tanggalLahir;
                  _alamat = result['alamat'] ?? _alamat;
                  _avatarUrl = result['avatar_url'] ?? _avatarUrl;
                });
              }
            });
          },
          child: const Text(
            'Edit Detail',
            style: TextStyle(
              color: Color(0xFF163A56),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  /// Widget info user
  Widget buildInfoItem(
      String label, String value, Color textColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: labelColor, fontSize: 14, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  /// Format tanggal ke bahasa Indonesia
  String formatTanggalIndo(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      DateTime date = DateTime.parse(tanggal);
      return DateFormat('d MMMM yyyy', 'id').format(date);
    } catch (_) {
      return tanggal;
    }
  }
}
