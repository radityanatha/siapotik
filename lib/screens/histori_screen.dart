import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/riwayat.dart';
import '../models/resep_detail.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/error_widget.dart';
import '../services/api_service.dart';

class HistoriScreen extends StatefulWidget {
  const HistoriScreen({super.key});

  @override
  State<HistoriScreen> createState() => _HistoriScreenState();
}

class _HistoriScreenState extends State<HistoriScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Riwayat> _riwayatList = [];

  @override
  void initState() {
    super.initState();
    _fetchCombinedRiwayat();
  }

  Future<void> _fetchCombinedRiwayat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 Memulai fetch data riwayat...');
      final List<Map<String, dynamic>> rawRiwayatList = await ApiService.getRiwayatList();

      if (rawRiwayatList.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Belum ada riwayat transaksi.';
        });
        return;
      }

      List<Future<Riwayat>> futures = [];
      for (var riwayatJson in rawRiwayatList) {
        futures.add(_fetchDetailsForRiwayat(riwayatJson));
      }

      final List<Riwayat> completedRiwayat = await Future.wait(futures);
      completedRiwayat.sort((a, b) => b.tanggalSelesai.compareTo(a.tanggalSelesai));

      setState(() {
        _riwayatList = completedRiwayat;
        _isLoading = false;
      });

      print('✅ Berhasil memuat ${_riwayatList.length} data riwayat');
    } catch (e) {
      print('❌ Error saat fetch data riwayat: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data riwayat: $e';
      });
    }
  }

  Future<Riwayat> _fetchDetailsForRiwayat(Map<String, dynamic> riwayatJson) async {
    final int resepId = riwayatJson['id_resep'];
    List<ResepDetail> details = [];
    String noRegistrasi = 'N/A';
    double totalKeseluruhan = 0.0;

    try {
      // Fetch detail resep
      final List<Map<String, dynamic>> detailListJson = await ApiService.getAntrianDetail(resepId);
      details = detailListJson.map((json) => ResepDetail.fromJson(json)).toList();

      // Coba ambil info antrian untuk mendapatkan no_registrasi dan total
      try {
        final List<Map<String, dynamic>> antrianList = await ApiService.getAntrianList();
        final antrianInfo = antrianList.firstWhere(
          (a) => a['id_resep'] == resepId,
          orElse: () => <String, dynamic>{},
        );

        if (antrianInfo.isNotEmpty) {
          noRegistrasi = antrianInfo['no_registrasi']?.toString() ?? 'N/A';
          totalKeseluruhan = double.tryParse(
                  antrianInfo['total_keseluruhan']?.toString() ?? '0.0') ??
              0.0;
        }
      } catch (e) {
        print('⚠️ Tidak bisa mengambil info antrian untuk resepId $resepId: $e');
      }

      // Jika total masih 0, hitung dari detail
      if (totalKeseluruhan == 0.0 && details.isNotEmpty) {
        totalKeseluruhan = details.fold(0.0, (sum, item) => sum + item.totalHarga);
      }

    } catch (e) {
      print('❌ Error saat fetch detail riwayat $resepId: $e');
    }

    return Riwayat(
      idRiwayat: riwayatJson['id_riwayat'],
      idResep: resepId,
      noRegistrasi: noRegistrasi,
      tanggalSelesai: DateTime.tryParse(riwayatJson['tanggal_selesai'] ?? '') ??
          DateTime.now(),
      status: riwayatJson['status'] ?? 'Selesai',
      totalKeseluruhan: totalKeseluruhan,
      details: details,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? CustomErrorWidget(
                    errorMessage: _errorMessage,
                    onRetry: _fetchCombinedRiwayat,
                    title: 'Gagal Memuat Data Riwayat',
                  )
                : RefreshIndicator(
                    onRefresh: _fetchCombinedRiwayat,
                    child: ListView.builder(
                      itemCount: _riwayatList.length,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final riwayat = _riwayatList[index];
                        return RiwayatCard(riwayat: riwayat);
                      },
                    ),
                  ),
      ),
    );
  }
}

// --- WIDGET KARTU UNTUK SETIAP RIWAYAT ---
class RiwayatCard extends StatelessWidget {
  final Riwayat riwayat;
  const RiwayatCard({super.key, required this.riwayat});

  // --- FUNGSI BARU UNTUK MENAMPILKAN DIALOG DETAIL ---
  void _showDetailDialog(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Detail Resep: ${riwayat.noRegistrasi}"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: riwayat.details.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final detail = riwayat.details[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(detail.namaObat ?? detail.idObat),
                  subtitle: Text(
                      "${detail.jumlah} pcs - Aturan: ${detail.aturanPakai}"),
                  trailing: Text(currencyFormatter.format(detail.totalHarga)),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Tutup"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter =
        DateFormat('EEEE, dd MMM flexibles HH:mm', 'id_ID');
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    String itemSummary;
    if (riwayat.details.isEmpty) {
      itemSummary = 'Tidak ada detail item.';
    } else if (riwayat.details.length == 1) {
      itemSummary =
          riwayat.details.first.namaObat ?? riwayat.details.first.idObat;
    } else {
      itemSummary =
          '${riwayat.details.first.namaObat ?? riwayat.details.first.idObat}, dan ${riwayat.details.length - 1} lainnya...';
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    riwayat.status.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        fontSize: 10),
                  ),
                ),
                // --- FUNGSI onTap DIPERBARUI DI SINI ---
                InkWell(
                  onTap: () => _showDetailDialog(context),
                  child: Text(
                    "Lihat Detail >",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "No. Resep: ${riwayat.noRegistrasi}",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              dateFormatter.format(riwayat.tanggalSelesai),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const Divider(height: 24),
            Text(
              itemSummary,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${riwayat.details.length} Item",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      currencyFormatter.format(riwayat.totalKeseluruhan),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
