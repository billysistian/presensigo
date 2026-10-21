import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pilih Bahasa',
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Image.asset('assets/images/language_illustration.png', height: 160),
            const SizedBox(height: 30),
            const Text(
              'Pilih Bahasa Yang Ingin anda gunakan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Choose Your Preferred Language',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _languageOption('Bahasa Indonesia'),
            const SizedBox(height: 12),
            _languageOption('English Language'),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedLanguage == null
                  ? null
                  : () {
                      // simpan pilihan bahasa ke localStorage atau SharedPreferences
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor:
                    selectedLanguage == null ? Colors.grey : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: const Text('Selanjutnya / Next'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(String language) {
    return InkWell(
      onTap: () => setState(() => selectedLanguage = language),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedLanguage == language
                ? Colors.blue
                : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language, style: const TextStyle(fontSize: 16)),
            Icon(
              selectedLanguage == language
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selectedLanguage == language ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
