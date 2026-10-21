import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdateChecker {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('https://payroll.gomega.co.id/api/app/version'),
      );

      if (response.statusCode != 200) {
        debugPrint("⚠️ Gagal mengambil versi dari server");
        return;
      }

      final data = jsonDecode(response.body);
      final latestVersion = data['version'];
      final apkUrl = data['url'];
      final forceUpdate = data['force_update'] == "1";
      final changelog = data['changelog'] ?? "";

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion =
          "${packageInfo.version}+${packageInfo.buildNumber}";

      debugPrint("🟢 Versi terbaru dari server: $latestVersion");
      debugPrint("🟣 Versi saat ini di device: $currentVersion");
      debugPrint("🔗 URL file APK: $apkUrl");
      debugPrint("📋 Catatan perubahan: $changelog");
      debugPrint("! Wajib update? ${forceUpdate ? 'Ya' : 'Tidak'}");

      if (_isVersionNewer(latestVersion, packageInfo.version)) {
        if (!context.mounted) return;
        _showUpdateDialog(
            context, latestVersion, apkUrl, changelog, forceUpdate);
      }
    } catch (e) {
      debugPrint("❌ Gagal memeriksa pembaruan: $e");
    }
  }

  static bool _isVersionNewer(String latest, String current) {
    try {
      final latestParts =
          latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts =
          current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      while (latestParts.length < 3) {
        latestParts.add(0);
      }
      while (currentParts.length < 3) {
        currentParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      debugPrint("⚠️ Error membandingkan versi: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------
  // 🚀 DOWNLOAD APK + PROGRESS + AUTO INSTALL
  // ---------------------------------------------------------------
  static Future<void> downloadAndInstallAPK(
      BuildContext context, String url) async {
    final dio = Dio();

    try {
      // Direktori penyimpanan APK
      Directory? dir = await getExternalStorageDirectory();
      if (dir == null) {
        throw "Direktori penyimpanan tidak ditemukan";
      }

      final savePath = "${dir.path}/update_app.apk";
      double progress = 0;

      // Modal progress
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (c) => StatefulBuilder(
          builder: (c, setState) {
            return AlertDialog(
              title: const Text("Mengunduh Pembaruan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 10),
                  Text("${(progress * 100).toStringAsFixed(0)}%"),
                ],
              ),
            );
          },
        ),
      );

      // Proses download
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            progress = received / total;
          }
        },
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context); // tutup progress modal

      // Buka installer APK otomatis
      await OpenFilex.open(savePath);
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Gagal"),
          content: Text("Gagal mengunduh pembaruan:\n$e"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  // ---------------------------------------------------------------
  // 🟦 POPUP UPDATE
  // ---------------------------------------------------------------
  static void _showUpdateDialog(
    BuildContext context,
    String latestVersion,
    String downloadUrl,
    String changelog,
    bool forceUpdate,
  ) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (ctx) => PopScope(
        canPop: !forceUpdate,
        child: AlertDialog(
          title: Text(
              forceUpdate ? "Pembaruan Wajib 🚨" : "Pembaruan Tersedia 🚀"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Versi baru: $latestVersion"),
              const SizedBox(height: 8),
              if (changelog.isNotEmpty) Text("Catatan perubahan:\n$changelog"),
            ],
          ),
          actions: [
            if (!forceUpdate)
              TextButton(
                child: const Text("Nanti"),
                onPressed: () => Navigator.pop(ctx),
              ),
            ElevatedButton(
              child: const Text("Perbarui Sekarang"),
              onPressed: () async {
                Navigator.pop(ctx);
                await downloadAndInstallAPK(context, downloadUrl);
              },
            ),
          ],
        ),
      ),
    );
  }
}
