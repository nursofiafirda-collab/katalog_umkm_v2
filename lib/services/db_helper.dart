import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/produk.dart';

class DbHelper {
  static Database? _db;

  /// Membuka database sekali, lalu dipakai ulang
  static Future<Database> get database async {
    _db ??= await _bukaDatabase();
    return _db!;
  }

  static Future<Database> _bukaDatabase() async {
    final lokasi = join(await getDatabasesPath(), 'katalog_umkm.db');

    return openDatabase(
      lokasi,
      version: 2,

      // Membuat database baru
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produk_cache (
            id INTEGER PRIMARY KEY,
            nama TEXT NOT NULL,
            harga INTEGER NOT NULL,
            deskripsi TEXT,
            gambar TEXT,
            kategori TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE keranjang (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            produk_id INTEGER NOT NULL,
            nama TEXT NOT NULL,
            harga INTEGER NOT NULL,
            jumlah INTEGER NOT NULL,
            waktu TEXT NOT NULL
          )
        ''');
      },

      // Memperbarui database versi lama ke versi baru
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE produk_cache ADD COLUMN kategori TEXT',
          );
        }
      },
    );
  }

  // ------------------------- CACHE PRODUK -------------------------

  static Future<void> simpanCache(List<Produk> daftar) async {
    final db = await database;
    final batch = db.batch();

    batch.delete('produk_cache');

    for (final p in daftar) {
      batch.insert('produk_cache', p.toMap());
    }

    await batch.commit(noResult: true);
  }

  static Future<List<Produk>> ambilCache() async {
    final db = await database;
    final baris = await db.query('produk_cache', orderBy: 'id');

    return baris.map((b) => Produk.fromMap(b)).toList();
  }

  // --------------------------- KERANJANG ---------------------------

  static Future<void> tambahKeranjang(
    Produk produk,
    int jumlah,
  ) async {
    final db = await database;

    await db.insert('keranjang', {
      'produk_id': produk.id,
      'nama': produk.nama,
      'harga': produk.harga,
      'jumlah': jumlah,
      'waktu': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> ambilKeranjang() async {
    final db = await database;
    return db.query('keranjang', orderBy: 'id DESC');
  }

  static Future<int> totalItem() async {
    final db = await database;

    final hasil = await db.rawQuery(
      'SELECT SUM(jumlah) AS total FROM keranjang',
    );

    return (hasil.first['total'] as int?) ?? 0;
  }

  // Menghapus satu item dari keranjang berdasarkan ID
  static Future<int> hapusItem(int id) async {
    final db = await database;

    return await db.delete(
      'keranjang',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mengubah jumlah item di keranjang
static Future<int> ubahJumlah(int id, int jumlah) async {
  final db = await database;

  return await db.update(
    'keranjang',
    {'jumlah': jumlah},
    where: 'id = ?',
    whereArgs: [id],
  );
}

  static Future<void> kosongkanKeranjang() async {
    final db = await database;
    await db.delete('keranjang');
  }
}