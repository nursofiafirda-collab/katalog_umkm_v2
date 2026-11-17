import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produk.dart';
 
class ApiService {
  static const _url = 'https://dummyjson.com/products/category/beauty';
 
  static Future<List<Produk>> ambilProduk() async {
    final response = await http
        .get(Uri.parse(_url))
        .timeout(const Duration(seconds: 10));
 
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat produk (kode ${response.statusCode})');
    }
 
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> daftar = data['products'];
    return daftar
        .map((item) => Produk.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}