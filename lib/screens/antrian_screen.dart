import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/antrian.dart';
import '../models/resep_detail.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/error_widget.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// --- WIDGET UNTUK SETIAP BARIS ANTRIAN (Expandable) ---
class AntrianRow extends StatefulWidget {
  final Antrian antrian;

  const AntrianRow({super.key, required this.antrian});

  @override
  State<AntrianRow> createState() => _AntrianRowState();
}

class _AntrianRowState extends State<AntrianRow> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.antrian.noRegistrasi,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800]),
                ),
                Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.indigo[800]),
              ],
            ),
          ),
        ),
        // --- Detail yang Bisa Expand/Collapse dengan Animasi ---
        AnimatedCrossFade(
          firstChild: Container(), // Widget kosong saat tidak expanded
          secondChild: _buildDetailCard(), // Widget detail saat expanded
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  // Helper widget untuk membangun kartu detail yang bisa diperluas
  Widget _buildDetailCard() {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Text("Item",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text("Jml",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 3,
                    child: Text("Harga",
                        textAlign: TextAlign.right,
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const Divider(),
            // --- List Obat ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.antrian.details.length,
              itemBuilder: (context, index) {
                final detail = widget.antrian.details[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: Text(detail.namaObat ?? detail.idObat)),
                      Expanded(
                          flex: 2,
                          child: Text('${detail.jumlah}',
                              textAlign: TextAlign.center)),
                      Expanded(
                          flex: 3,
                          child: Text(
                            currencyFormatter.format(detail.totalHarga),
                            textAlign: TextAlign.right,
                          )),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            // --- Total Harga ---
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                      currencyFormatter.format(widget.antrian.totalKeseluruhan),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // --- Baris Status dan Tombol Aksi ---
            Row(
              children: [
                const Text("Status",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text("Lunas",
                      style: TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: IconButton.filled(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    style:
                        IconButton.styleFrom(backgroundColor: Colors.red[100]),
                    icon: Icon(Icons.close, color: Colors.red[700]),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: IconButton.filled(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.green[100]),
                    icon: Icon(Icons.check, color: Colors.green[800]),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCREEN UTAMA ---
class AntrianScreen extends StatefulWidget {
  const AntrianScreen({super.key});

  @override
  State<AntrianScreen> createState() => _AntrianScreenState();
}

class _AntrianScreenState extends State<AntrianScreen> {
  List<Antrian> antrianList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAndCombineData();
  }

  Future<void> fetchAndCombineData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 Memulai fetch data antrian...');
      final List<Map<String, dynamic>> rawAntrianList = await ApiService.getAntrianList();

      if (rawAntrianList.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Saat ini tidak ada antrian resep.';
        });
        return;
      }

      List<Future<Antrian>> futures = [];
      for (var antrianJson in rawAntrianList) {
        futures.add(_fetchDetailForAntrian(antrianJson));
      }

      final List<Antrian> completedAntrians = await Future.wait(futures);

      setState(() {
        antrianList = completedAntrians;
        _isLoading = false;
        _errorMessage = '';
      });

      print('✅ Berhasil memuat ${antrianList.length} data antrian');
    } catch (e) {
      print('❌ Error saat fetch data antrian: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = "Gagal memproses data antrian: ${e.toString()}";
      });
    }
  }

  Future<Antrian> _fetchDetailForAntrian(Map<String, dynamic> antrianJson) async {
    final int resepId = antrianJson['id_resep'];

    try {
      final List<Map<String, dynamic>> detailListJson = await ApiService.getAntrianDetail(resepId);
      final List<ResepDetail> details = detailListJson.map((json) => ResepDetail.fromJson(json)).toList();

      return Antrian(
        idResep: resepId,
        noRegistrasi: antrianJson['no_registrasi']?.toString() ?? 'N/A',
        totalKeseluruhan: double.tryParse(
                antrianJson['total_keseluruhan']?.toString() ?? '0.0') ??
            0.0,
        details: details,
      );
    } catch (e) {
      print('❌ Error saat fetch detail antrian $resepId: $e');
      return Antrian(
        idResep: resepId,
        noRegistrasi: antrianJson['no_registrasi']?.toString() ?? 'N/A',
        totalKeseluruhan: double.tryParse(
                antrianJson['total_keseluruhan']?.toString() ?? '0.0') ??
            0.0,
        details: [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          onSelected: (value) {
            if (value == 'profil') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Profil belum tersedia')),
              );
            } else if (value == 'logout') {
              // Logout dan redirect ke login
              AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout berhasil'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'profil', child: Text('Profil')),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      title: "Antrean",
                      value: antrianList.isNotEmpty
                          ? antrianList.first.noRegistrasi
                          : 'N/A',
                      color: const Color(0xFF2C5DBA),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoCard(
                      title: "Total Antrean",
                      value: antrianList.length.toString().padLeft(3, '0'),
                      color: const Color(0xFF1B4A9C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? CustomErrorWidget(
                            errorMessage: _errorMessage,
                            onRetry: fetchAndCombineData,
                            title: 'Gagal Memuat Data Antrian',
                          )
                        : RefreshIndicator(
                            onRefresh: fetchAndCombineData,
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              color: Colors.blue[50],
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                                    child: Text("Antrean Resep",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                  const Divider(height: 1),
                                  Expanded(
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: antrianList.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                              height: 1,
                                              indent: 16,
                                              endIndent: 16),
                                      itemBuilder: (context, index) {
                                        final antrian = antrianList[index];
                                        return AntrianRow(antrian: antrian);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 38,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
