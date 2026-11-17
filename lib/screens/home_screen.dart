
import 'package:flutter/material.dart';
import '../models/produk.dart';
import '../services/db_helper.dart';
import '../services/prefs_service.dart';
import '../services/produk_repository.dart';
import 'detail_screen.dart';
import 'keranjang_screen.dart';

class HomeScreen extends StatefulWidget {
  final String namaPengguna;

  const HomeScreen({super.key, required this.namaPengguna});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Produk> _produk = [];
  bool _memuat = true;
  bool _modeOffline = false;
  String? _pesanError;
  int _totalItem = 0;
  DateTime? _waktuLogin;
  DateTime? _waktuSinkronisasi;

  @override
  void initState() {
    super.initState();
    _muatWaktuLogin();
    _muatWaktuSinkronisasi();
    _muatData(tampilkanLoading: false);
  }

  Future<void> _muatData({bool tampilkanLoading = true}) async {
    if (tampilkanLoading) {
      setState(() {
        _memuat = true;
        _pesanError = null;
      });
    }

    try {
      final hasil = await ProdukRepository.ambilProduk();
      final total = await DbHelper.totalItem();
      final waktuSinkronisasi =
          await PrefsService.ambilWaktuSinkronisasi();

      if (!mounted) return;

      setState(() {
        _produk = hasil.produk;
        _modeOffline = hasil.dariCache;
        _totalItem = total;
        _waktuSinkronisasi = waktuSinkronisasi;
        _pesanError = null;
        _memuat = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _pesanError =
            'Produk belum bisa dimuat.\nPeriksa koneksi internet Anda.';
        _memuat = false;
      });
    }
  }

  Future<void> _bukaDetail(Produk produk) async {
    final jumlah = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(produk: produk),
      ),
    );

    if (jumlah == null || jumlah <= 0) return;

    await DbHelper.tambahKeranjang(produk, jumlah);

    final total = await DbHelper.totalItem();

    if (!mounted) return;

    setState(() => _totalItem = total);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$jumlah x ${produk.nama} disimpan ke keranjang'),
      ),
    );
  }

  Future<void> _bukaKeranjang() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KeranjangScreen(),
      ),
    );

    final total = await DbHelper.totalItem();

    if (!mounted) return;

    setState(() => _totalItem = total);
  }

  Future<void> _keluar() async {
    await PrefsService.hapusNama();

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  // Mengambil waktu login terakhir
  Future<void> _muatWaktuLogin() async {
    final waktu = await PrefsService.ambilWaktuLogin();

    if (!mounted) return;

    setState(() {
      _waktuLogin = waktu;
    });
  }

  // Mengambil waktu terakhir sinkronisasi data
Future<void> _muatWaktuSinkronisasi() async {
  final waktu = await PrefsService.ambilWaktuSinkronisasi();

  if (!mounted) return;

  setState(() {
    _waktuSinkronisasi = waktu;
  });
}

  // Mengubah format waktu menjadi tanggal dan jam
  String _formatWaktu(DateTime waktu) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return '${waktu.day} ${bulan[waktu.month - 1]} ${waktu.year}, '
        '${waktu.hour.toString().padLeft(2, '0')}:'
        '${waktu.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk Kecantikan'),
        actions: [
          IconButton(
            tooltip: 'Keranjang',
            onPressed: _bukaKeranjang,
            icon: Badge(
              isLabelVisible: _totalItem > 0,
              label: Text('$_totalItem'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Tentang',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: _keluar,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Halo, ${widget.namaPengguna}!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // Menampilkan waktu login terakhir
          if (_waktuLogin != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Login terakhir: ${_formatWaktu(_waktuLogin!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

          if (_modeOffline)
  Container(
    color: Colors.orange.shade100,
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mode offline: menampilkan data tersimpan',
              ),
              if (_waktuSinkronisasi != null)
                Text(
                  'Data terakhir diperbarui: '
                  '${_formatWaktu(_waktuSinkronisasi!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    ),
  ),

          Expanded(child: _isiBody()),
        ],
      ),
    );
  }

  Widget _isiBody() {
    if (_memuat) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_pesanError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 64),
              const SizedBox(height: 12),
              Text(
                _pesanError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _muatData,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _muatData(tampilkanLoading: false),
      child: ListView.builder(
        itemCount: _produk.length,
        itemBuilder: (context, index) {
          final produk = _produk[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  produk.gambar,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              title: Text(produk.nama),
              subtitle: Text(formatRupiah(produk.harga)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _bukaDetail(produk),
            ),
          );
        },
      ),
    );
  }
}