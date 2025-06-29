import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/antrian_screen.dart';
import 'screens/histori_screen.dart';
import 'screens/stok_obat_screen.dart';
import 'http_overrides.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIaPotik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F6F8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.black87,
            titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          )),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/antrian': (context) => const AntrianScreen(),
        '/histori': (context) => const HistoriScreen(),
        '/stok': (context) => const StokObatScreen(),
      },
    );
  }
}
