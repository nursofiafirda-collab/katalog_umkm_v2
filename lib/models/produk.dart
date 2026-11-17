
class Produk {
  final int id;
  final String nama;
  final int harga;
  final String deskripsi;
  final String gambar;
  final String kategori;

  const Produk({
    required this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    required this.gambar,
    required this.kategori,
  });

  /// Dari JSON response API (dummyjson.com)
  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'] as int,
      nama: json['title'] as String,
      harga: ((json['price'] as num) * 16000).round(),
      deskripsi: json['description'] as String,
      gambar: json['thumbnail'] as String,
      kategori: json['category'] as String? ?? 'Lainnya',
    );
  }

  /// Ke baris tabel SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'kategori': kategori,
    };
  }

  /// Dari baris tabel SQLite
  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'] as int,
      nama: map['nama'] as String,
      harga: map['harga'] as int,
      deskripsi: map['deskripsi'] as String,
      gambar: map['gambar'] as String,
      kategori: map['kategori'] as String? ?? 'Lainnya',
    );
  }
}

/// Mengubah 45000 menjadi "Rp 45.000"
String formatRupiah(int angka) {
  final s = angka.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(s[i]);
  }

  return 'Rp $buffer';
}