import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login/login_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Set default gaya system bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.grey[100]!,
    systemNavigationBarDividerColor: Colors.grey[100]!,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  bool loggedIn = false;
  String userName = "User";
  String? avatarUrl;
  String? email;
  String? tanggalLahir;
  String? alamat;
  String? role;

  try {
    loggedIn = await AuthService.checkSession();
    if (loggedIn) {
      userName = await AuthService.getUserName();
      avatarUrl = await AuthService.getAvatarUrl();
      email = await AuthService.getEmail();
      tanggalLahir = await AuthService.getTanggalLahir();
      alamat = await AuthService.getAlamat();
      role = await AuthService.getRole();
    }
  } catch (_) {
    loggedIn = false;
  }

  runApp(MyApp(
    isLoggedIn: loggedIn,
    userName: userName,
    avatarUrl: avatarUrl,
    email: email,
    tanggalLahir: tanggalLahir,
    alamat: alamat,
    role: role,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;
  final String? avatarUrl;
  final String? email;
  final String? tanggalLahir;
  final String? alamat;
  final String? role;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.userName,
    this.avatarUrl,
    this.email,
    this.tanggalLahir,
    this.alamat,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Presensi App",
      theme: ThemeData(useMaterial3: false, primarySwatch: Colors.blue),

      // ✅ Builder global untuk semua halaman
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.grey[100]!,
            systemNavigationBarDividerColor: Colors.grey[100]!,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      // ✅ Tentukan halaman pertama
      home: isLoggedIn
          ? MenuScreen(
              userName: userName,
              avatarUrl: avatarUrl,
              email: email,
              tanggalLahir: tanggalLahir,
              alamat: alamat,
              role: role,
            )
          : const LoginScreen(),

      // ✅ Bahasa
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
      ],
      locale: const Locale('id', 'ID'),

      // ✅ Rute tambahan
      routes: {
        '/menu': (context) => MenuScreen(
              userName: userName,
              avatarUrl: avatarUrl,
              email: email,
              tanggalLahir: tanggalLahir,
              alamat: alamat,
              role: role,
            ),
      },
    );
  }
}
