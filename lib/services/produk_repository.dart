import '../models/produk.dart';
import 'api_service.dart';
import 'db_helper.dart';
import 'prefs_service.dart';

class HasilProduk {
  final List<Produk> produk;
  final bool dariCache; // true = sedang offline
 
  const HasilProduk(this.produk, this.dariCache);
}
 
class ProdukRepository {
  static Future<HasilProduk> ambilProduk() async {
    try {
  final produk = await ApiService.ambilProduk();
  await DbHelper.simpanCache(produk);

  // Simpan waktu setelah data berhasil diperbarui
  await PrefsService.simpanWaktuSinkronisasi();

  return HasilProduk(produk, false);
  }catch (e) {
      final cache = await DbHelper.ambilCache();     // 3. gagal? pakai cache
      if (cache.isEmpty) rethrow;                    // 4. cache kosong -> error
      return HasilProduk(cache, true);
    }
  }
}