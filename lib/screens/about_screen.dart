
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Katalog Produk Kecantikan v2.0',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Tugas Mobile Computing - Pertemuan 9'),

            const SizedBox(height: 20),

            const Text(
              'Tentang Produk Kecantikan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Katalog Kecantikan mempunyai beberapa produk kecantikan'
              ' yang bisa Anda pilih sesuai dengan tipe kulit Anda.',
              textAlign: TextAlign.justify,
            ),

            const Divider(height: 32),

            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Firda Nur Sopiarahma'),
              subtitle: Text(
                'NIM: 2404060017 | Sistem Informasi - 5A',
              ),
            ),

            const Spacer(),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
