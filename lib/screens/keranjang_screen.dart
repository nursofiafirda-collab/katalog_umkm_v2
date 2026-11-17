
import 'package:flutter/material.dart';
import '../models/produk.dart';
import '../services/db_helper.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  List<Map<String, dynamic>> _isi = [];
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  // Memuat data keranjang dari database
  Future<void> _muat() async {
    final data = await DbHelper.ambilKeranjang();

    if (!mounted) return;

    setState(() {
      _isi = data;
      _memuat = false;
    });
  }

  // Menghitung total harga seluruh item
  int get _totalHarga => _isi.fold<int>(
        0,
        (total, item) =>
            total + (item['harga'] as int) * (item['jumlah'] as int),
      );

  // Menghapus satu item dengan geser
  Future<void> _hapusItem(int id) async {
    try {
      final jumlahTerhapus = await DbHelper.hapusItem(id);

      if (!mounted) return;

      await _muat();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            jumlahTerhapus > 0
                ? 'Item berhasil dihapus dari keranjang'
                : 'Item tidak ditemukan di database',
          ),
        ),
      );
    } catch (e) {
      await _muat();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus item: $e'),
        ),
      );
    }
  }

  // Mengubah jumlah produk

Future<void> _ubahJumlah(int id, int jumlahSaatIni) async {
  final jumlahBaru = await showDialog<int>(
    context: context,
    builder: (context) {
      return DialogUbahJumlah(
        jumlahSaatIni: jumlahSaatIni,
      );
    },
  );

  if (jumlahBaru == null) return;

  await DbHelper.ubahJumlah(id, jumlahBaru);
  await _muat();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Jumlah produk berhasil diperbarui'),
    ),
  );
}

  // Mengosongkan seluruh keranjang
  Future<void> _kosongkan() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan keranjang?'),
        content: const Text('Semua item akan dihapus dari penyimpanan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    await DbHelper.kosongkanKeranjang();
    await _muat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          IconButton(
            tooltip: 'Kosongkan',
            icon: const Icon(Icons.delete_outline),
            onPressed: _isi.isEmpty ? null : _kosongkan,
          ),
        ],
      ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _isi.isEmpty
              ? const Center(
                  child: Text('Keranjang masih kosong'),
                )
              : ListView.builder(
                  itemCount: _isi.length,
                  itemBuilder: (context, index) {
                    final item = _isi[index];
                    final id = item['id'] as int;
                    final harga = item['harga'] as int;
                    final jumlah = item['jumlah'] as int;

                    return Dismissible(
                      key: ValueKey(id),
                      direction: DismissDirection.endToStart,

                      // Latar belakang saat item digeser ke kiri
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),

                      // Menghapus item setelah digeser
                      onDismissed: (direction) {
                        _hapusItem(id);
                      },

                      
child: ListTile(
  leading: CircleAvatar(
    child: Text('$jumlah'),
  ),
  title: Text(item['nama'] as String),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$jumlah x ${formatRupiah(harga)}'),
      const SizedBox(height: 4),
      Text(
        'Total: ${formatRupiah(harga * jumlah)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      TextButton(
        onPressed: () => _ubahJumlah(id, jumlah),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
        ),
        child: const Text('Ubah jumlah'),
      ),
    ],
  ),
),
                    );
                  },
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Total: ${formatRupiah(_totalHarga)}',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}


class DialogUbahJumlah extends StatefulWidget {
  final int jumlahSaatIni;

  const DialogUbahJumlah({
    super.key,
    required this.jumlahSaatIni,
  });

  @override
  State<DialogUbahJumlah> createState() =>
      _DialogUbahJumlahState();
}

class _DialogUbahJumlahState extends State<DialogUbahJumlah> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.jumlahSaatIni.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah jumlah produk'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Jumlah baru',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final jumlah = int.tryParse(_controller.text);

            if (jumlah != null && jumlah > 0) {
              Navigator.pop(context, jumlah);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Masukkan jumlah minimal 1'),
                ),
              );
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
