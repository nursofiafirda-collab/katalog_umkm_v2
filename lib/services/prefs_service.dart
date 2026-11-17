import 'package:shared_preferences/shared_preferences.dart';
 
class PrefsService {
  static const _kunciNama = 'nama_pengguna';
 
  static Future<void> simpanNama(String nama) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kunciNama, nama);
  }
 
  /// Mengembalikan null jika belum pernah login
  static Future<String?> ambilNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kunciNama);
  }
 
  static Future<void> hapusNama() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kunciNama);
  }

  
  // Menyimpan waktu login terakhir
  static const _kunciWaktuLogin = 'waktu_login_terakhir';

  static Future<void> simpanWaktuLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kunciWaktuLogin,
      DateTime.now().toIso8601String(),
    );
  }

  // Mengambil waktu login terakhir
  static Future<DateTime?> ambilWaktuLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final waktu = prefs.getString(_kunciWaktuLogin);

    if (waktu == null) return null;

    return DateTime.tryParse(waktu)?.toLocal();
  }

    // Menyimpan waktu sinkronisasi data terakhir
  static const _kunciWaktuSinkronisasi = 'waktu_sinkronisasi';

  static Future<void> simpanWaktuSinkronisasi() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kunciWaktuSinkronisasi,
      DateTime.now().toIso8601String(),
    );
  }

  // Mengambil waktu sinkronisasi data terakhir
  static Future<DateTime?> ambilWaktuSinkronisasi() async {
    final prefs = await SharedPreferences.getInstance();
    final waktu = prefs.getString(_kunciWaktuSinkronisasi);

    if (waktu == null) return null;

    return DateTime.tryParse(waktu)?.toLocal();
  }

}