import 'package:flutter/material.dart';
import 'screens/about_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/prefs_service.dart';
 
Future<void> main() async {
  // wajib dipanggil sebelum memakai plugin di dalam main()
  WidgetsFlutterBinding.ensureInitialized();
  final namaTersimpan = await PrefsService.ambilNama();
  runApp(KatalogApp(namaTersimpan: namaTersimpan));
}
 
class KatalogApp extends StatelessWidget {
  final String? namaTersimpan;
 
  const KatalogApp({super.key, this.namaTersimpan});
 
  @override
  Widget build(BuildContext context) {
    final nama = namaTersimpan;
    return MaterialApp(
      title: 'Katalog Produk Kecantikan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: nama == null ? const LoginScreen() : HomeScreen(namaPengguna: nama),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
